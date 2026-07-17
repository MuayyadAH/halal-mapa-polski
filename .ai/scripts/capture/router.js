/**
 * Capture Router — inject and run capture scripts without loading them into LLM context.
 *
 * Usage: Read ONLY this file, set CMD and OPTS below, pass to browser_run_code.
 * The actual extraction script loads from disk via addScriptTag (bypasses context window).
 *
 * Commands:
 *   styles           → Style + icon + color extraction → save to styles.json
 *                      Returns { styles, icons, colors } — colors array is the Element Color Map
 *                      OPTS: { containerSelector: '...' } for element scope, omit for page-level
 *   snapshot         → Accessibility snapshot → save to snapshot.md
 *                      OPTS: { selector: '...' } for element scope,
 *                      OPTS: { contentSelectors: [...] } for page content scope, omit for defaults
 *   modal-position   → Modal position/backdrop CSS detection
 *                      OPTS: { modalSelector: '...', backdropSelector: '...' }
 *
 * Legacy aliases (backward compatible):
 *   page-styles      → styles (no containerSelector)
 *   element-styles   → styles (with containerSelector)
 *   snapshot-content  → snapshot (with contentSelectors)
 *   snapshot-element  → snapshot (with selector)
 */
async (page) => {
  const DIR = '__PROJECT_ROOT__/.ai/scripts/capture';
  const CMD = '__CMD__';
  const OPTS = {};

  // Map legacy command names to unified script files
  const SCRIPT_MAP = {
    'page-styles': 'styles',
    'element-styles': 'styles',
    'snapshot-content': 'snapshot',
    'snapshot-element': 'snapshot'
  };
  const scriptFile = SCRIPT_MAP[CMD] || CMD;

  await page.addScriptTag({ path: `${DIR}/${scriptFile}.js` });
  return await page.evaluate(({ cmd, opts }) => window.__capture[cmd](opts), { cmd: CMD, opts: OPTS });
}
