// Cerbral auth — shared helpers for the sign-in flow.
//
// Backend: Supabase (email OTP + GitHub OAuth). All credentials stay on
// Supabase's side; our landing site only talks to it over HTTPS with the
// anon key. Cerbral Cloud never stores session content — only the tuple
// { email, github_handle, brain_repo_url } needed to route the user back.
//
// Flow (MVP, same-browser):
//   1. /signup  → enter email → supabase.auth.signInWithOtp
//   2. email  → magic link to /verify
//   3. /verify → supabase.auth handles the redirect, session established
//   4. /onboard → GitHub OAuth via supabase.auth.signInWithOAuth
//   5. /welcome → create private brain repo, show "Open Cerbral.app"
//
// Cross-device fallback (the "enter this code on the original browser"
// screen) requires an edge function and a `pending_auth` table; see
// docs/SUPABASE_SETUP.md for the schema + function code. Until those are
// deployed, open the magic link on the same browser where you signed up.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// Populated from site/config.js (not checked into git for prod).
const cfg = window.CERBRAL_CONFIG || {};
if (!cfg.SUPABASE_URL || !cfg.SUPABASE_ANON_KEY) {
  console.warn(
    'Cerbral auth: missing SUPABASE_URL / SUPABASE_ANON_KEY. ' +
    'Copy site/config.sample.js to site/config.js and fill in your project values.'
  );
}

export const supabase = createClient(
  cfg.SUPABASE_URL || 'https://placeholder.supabase.co',
  cfg.SUPABASE_ANON_KEY || 'placeholder_anon_key',
  {
    auth: {
      flowType: 'pkce',
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true,
    },
  }
);

export const SITE_URL = window.location.origin;

// Deep-link scheme the Cerbral.app macOS bundle registers. Opened from
// the /welcome page once auth is complete.
export const DESKTOP_SCHEME = 'cerbral://';

/** Kick off sign-in. Sends a magic link via Supabase. */
export async function sendMagicLink(email) {
  const redirectTo = `${SITE_URL}/verify`;
  const { error } = await supabase.auth.signInWithOtp({
    email,
    options: {
      emailRedirectTo: redirectTo,
      // shouldCreateUser=true (default) → signup+login are the same flow.
    },
  });
  if (error) throw error;
  localStorage.setItem('cerbral:pending_email', email);
}

/** Kick off GitHub OAuth. Called from /onboard. */
export async function connectGitHub() {
  const redirectTo = `${SITE_URL}/welcome`;
  const { error } = await supabase.auth.signInWithOAuth({
    provider: 'github',
    options: {
      redirectTo,
      // `repo` lets Cerbral create the user's private brain repo.
      scopes: 'repo user:email',
    },
  });
  if (error) throw error;
}

/** Resolve the current session (or null). */
export async function getSession() {
  const { data, error } = await supabase.auth.getSession();
  if (error) throw error;
  return data.session;
}

export async function getUser() {
  const { data, error } = await supabase.auth.getUser();
  if (error) return null;
  return data.user;
}

/** Sign out locally. */
export async function signOut() {
  await supabase.auth.signOut();
}

/**
 * Create the user's private brain repo on GitHub after OAuth succeeds.
 * Uses the `provider_token` (GitHub token) from the Supabase session.
 */
export async function ensureBrainRepo(session, repoName = 'cerbral-brain') {
  const token = session?.provider_token;
  if (!token) throw new Error('GitHub provider token missing on session.');

  // Does it already exist? (Idempotent — re-sign-in shouldn't create duplicates.)
  const whoRes = await fetch('https://api.github.com/user', {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!whoRes.ok) throw new Error(`GitHub /user failed: ${whoRes.status}`);
  const me = await whoRes.json();

  const existRes = await fetch(
    `https://api.github.com/repos/${me.login}/${repoName}`,
    { headers: { Authorization: `Bearer ${token}` } }
  );
  if (existRes.ok) {
    return { repo: await existRes.json(), created: false, user: me };
  }

  const createRes = await fetch('https://api.github.com/user/repos', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      Accept: 'application/vnd.github+json',
    },
    body: JSON.stringify({
      name: repoName,
      description:
        'My Cerbral brain — memories, sessions, and self-improvement ' +
        'history for my local Cerbral agent. Private, owned by me.',
      private: true,
      auto_init: true,
    }),
  });
  if (!createRes.ok) {
    const body = await createRes.text();
    throw new Error(`GitHub create repo failed: ${createRes.status} ${body}`);
  }
  return { repo: await createRes.json(), created: true, user: me };
}

/**
 * List files under a directory in the user's cerbral-brain repo via
 * the GitHub Contents API. Used by Cerbral Web to show past sessions
 * without Cerbral Cloud ever storing or touching them. All requests
 * go browser → GitHub directly using the user's provider_token.
 *
 * Returns [{ name, path, size, sha }] or [] if dir doesn't exist.
 */
export async function listBrainDir(session, path, repoName = 'cerbral-brain') {
  const token = session?.provider_token;
  if (!token) throw new Error('GitHub token missing');
  const user = session.user?.user_metadata?.user_name
    || session.user?.identities?.find((i) => i.provider === 'github')?.identity_data?.user_name;
  if (!user) throw new Error('GitHub username missing');
  const url = `https://api.github.com/repos/${user}/${repoName}/contents/${encodeURI(path)}`;
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${token}`, Accept: 'application/vnd.github+json' },
  });
  if (res.status === 404) return [];
  if (!res.ok) throw new Error(`GitHub ${res.status}: ${await res.text()}`);
  const data = await res.json();
  if (!Array.isArray(data)) return [];
  return data
    .filter((f) => f.type === 'file')
    .map((f) => ({ name: f.name, path: f.path, size: f.size, sha: f.sha }));
}

/**
 * Read a single file from the user's cerbral-brain repo. Returns the
 * decoded text content.
 */
export async function readBrainFile(session, path, repoName = 'cerbral-brain') {
  const token = session?.provider_token;
  if (!token) throw new Error('GitHub token missing');
  const user = session.user?.user_metadata?.user_name
    || session.user?.identities?.find((i) => i.provider === 'github')?.identity_data?.user_name;
  if (!user) throw new Error('GitHub username missing');
  const url = `https://api.github.com/repos/${user}/${repoName}/contents/${encodeURI(path)}`;
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${token}`, Accept: 'application/vnd.github+json' },
  });
  if (!res.ok) throw new Error(`GitHub ${res.status}: ${await res.text()}`);
  const data = await res.json();
  if (data.encoding !== 'base64') throw new Error(`Unexpected encoding ${data.encoding}`);
  // atob → UTF-8 decode via TextDecoder (handles emoji, non-ASCII).
  const bin = atob(data.content.replace(/\s/g, ''));
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return new TextDecoder('utf-8').decode(bytes);
}

/**
 * Read the user's Cerbral profile row. Returns null if the row doesn't
 * exist yet (first-timer) OR if the profiles table isn't wired (which
 * is a non-fatal degradation — callers can fall through to the usual
 * GitHub detect-or-create flow).
 */
export async function getProfile() {
  const user = await getUser();
  if (!user) return null;
  const { data, error } = await supabase
    .from('profiles')
    .select('email, github_handle, brain_repo_url')
    .eq('user_id', user.id)
    .maybeSingle();
  if (error) {
    console.warn('getProfile skipped:', error);
    return null;
  }
  return data || null;
}

/**
 * Upsert the user's Cerbral profile row (email, github_handle, brain_repo_url).
 * Requires a `profiles` table with RLS policies — see SUPABASE_SETUP.md.
 */
export async function saveProfile({ githubHandle, brainRepoUrl }) {
  const user = await getUser();
  if (!user) throw new Error('No session.');
  const { error } = await supabase
    .from('profiles')
    .upsert({
      user_id: user.id,
      email: user.email,
      github_handle: githubHandle,
      brain_repo_url: brainRepoUrl,
      updated_at: new Date().toISOString(),
    });
  if (error) throw error;
}

/**
 * Build the deep link the /welcome page uses to hand the session back to
 * the desktop app. The desktop registers the `cerbral://` scheme on
 * install; clicking this URL focuses Cerbral.app and delivers the tokens
 * which it then stores in the OS Keychain.
 */
export function buildDesktopHandoff(session, { brainRepoUrl, githubHandle }) {
  const payload = {
    access_token: session.access_token,
    refresh_token: session.refresh_token,
    expires_at: session.expires_at,
    // provider_token is the GitHub OAuth token — Cerbral Desktop needs
    // this to verify the brain is connected AND to push commits to the
    // user's cerbral-brain repo. Without it, desktop sees the session
    // but treats the brain as disconnected.
    provider_token: session.provider_token,
    provider_refresh_token: session.provider_refresh_token,
    email: session.user?.email,
    // Surface the full user block so desktop can read `user.identities`
    // (for GitHub-linked detection) without re-fetching.
    user: session.user,
    github_handle: githubHandle,
    brain_repo_url: brainRepoUrl,
  };
  const encoded = btoa(unescape(encodeURIComponent(JSON.stringify(payload))));
  return `${DESKTOP_SCHEME}auth/success#payload=${encoded}`;
}
