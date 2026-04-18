// Cerbral landing page — install-code typing animation + click-to-copy.
(function () {
  'use strict';

  const INSTALL_CMD = 'curl -fsSL https://raw.githubusercontent.com/rumizenzz/cerbral/main/install.sh | bash';

  const typedEl   = document.getElementById('typed');
  const caretEl   = document.getElementById('caret');
  const codeEl    = document.getElementById('installCode');
  const hintEl    = document.getElementById('copyHint');

  if (!typedEl || !codeEl) return;

  // --- Typing animation ----------------------------------------------------
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  if (prefersReducedMotion) {
    typedEl.textContent = INSTALL_CMD;
  } else {
    let i = 0;
    function tick() {
      if (i <= INSTALL_CMD.length) {
        typedEl.textContent = INSTALL_CMD.slice(0, i);
        i++;
        // Vary the delay slightly so it doesn't feel mechanical.
        const delay = 22 + Math.random() * 30;
        setTimeout(tick, delay);
      } else if (caretEl) {
        // Once done typing, keep the caret but slow its blink.
        caretEl.style.animationDuration = '1.4s';
      }
    }
    // Small initial delay so the hero animation lands first.
    setTimeout(tick, 650);
  }

  // --- Click to copy -------------------------------------------------------
  function showCopied() {
    if (!hintEl) return;
    const original = hintEl.textContent;
    hintEl.textContent = 'copied ✓';
    codeEl.classList.add('copied');
    setTimeout(() => {
      hintEl.textContent = original;
      codeEl.classList.remove('copied');
    }, 1600);
  }

  async function copyCmd() {
    try {
      await navigator.clipboard.writeText(INSTALL_CMD);
      showCopied();
    } catch (err) {
      // Fallback for browsers without clipboard API permission.
      const ta = document.createElement('textarea');
      ta.value = INSTALL_CMD;
      ta.style.position = 'fixed';
      ta.style.opacity = '0';
      document.body.appendChild(ta);
      ta.select();
      try { document.execCommand('copy'); showCopied(); } catch (_) { /* noop */ }
      document.body.removeChild(ta);
    }
  }

  codeEl.addEventListener('click', copyCmd);
  codeEl.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      copyCmd();
    }
  });
})();
