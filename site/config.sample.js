// Copy this file to site/config.js and fill in the values from your
// Supabase project. `config.js` is gitignored — don't commit real keys.
//
// The anon key is safe to ship to the browser; it's scoped by row-level
// security policies. The service_role key (used by edge functions only)
// must NEVER appear in this file or any other file served by Netlify.
window.CERBRAL_CONFIG = {
  SUPABASE_URL: 'https://YOUR-PROJECT-REF.supabase.co',
  SUPABASE_ANON_KEY: 'YOUR_ANON_KEY',
};
