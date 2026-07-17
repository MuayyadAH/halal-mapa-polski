/**
 * Accessibility-like Snapshot — page content or element-scoped.
 * Pure browser-side script — loaded via addScriptTag, never enters LLM context.
 *
 * Registers: window.__capture['snapshot'](opts)
 * Options:
 *   selector          - CSS selector for a specific element (modal, panel, dropdown)
 *   contentSelectors  - array of CSS selectors to find page content container (omit selector to use)
 *                       Defaults: ['main', '[role="main"]', '#main-content', '[class*="content-area"]', ...]
 *
 * Priority:
 *   1. If opts.selector is set → snapshot that element
 *   2. Else → try contentSelectors array, return first match
 *   3. If nothing found → return FALLBACK message
 *
 * Returns: text tree of the matched element, or FALLBACK message
 *
 * Selector presets (pass via opts.selector):
 *   Modal:    '[role="dialog"], [class*="modal"], [class*="Modal"], [class*="drawer"]'
 *   Dropdown: '[role="listbox"], [class*="dropdown-menu"], [class*="select-panel"], .cdk-overlay-pane'
 *   Tab:      '[role="tabpanel"], [class*="tab-pane"]:not([hidden])'
 *   Panel:    '[class*="panel"]:not(nav [class*="panel"]), [class*="sidebar-detail"]'
 */
window.__capture = window.__capture || {};
window.__capture['snapshot'] = function(opts) {
  opts = opts || {};

  var root;
  if (opts.selector) {
    // Element-scoped: find specific element
    root = document.querySelector(opts.selector);
    if (!root) return 'Element not found with selectors: ' + opts.selector;
  } else {
    // Content-scoped: try fallback selectors for main content area
    var contentSelectors = opts.contentSelectors || [
      'main',
      '[role="main"]',
      '#main-content',
      '[class*="content-area"]',
      '[class*="page-content"]',
      '[class*="main-content"]'
    ];
    for (var i = 0; i < contentSelectors.length; i++) {
      root = document.querySelector(contentSelectors[i]);
      if (root) break;
    }
    if (!root) return 'FALLBACK: No main content container found. Use full browser_snapshot instead.';
  }

  function tree(node, depth) {
    depth = depth || 0;
    if (!node.tagName) {
      var text = node.textContent ? node.textContent.trim() : '';
      return text ? '  '.repeat(depth) + 'text "' + text.slice(0, 80) + '"\n' : '';
    }

    var tag = node.tagName.toLowerCase();
    var ariaRole = node.getAttribute('role');
    var label = node.getAttribute('aria-label') || '';
    var labelledBy = node.getAttribute('aria-labelledby') || '';
    var placeholder = node.getAttribute('placeholder') || '';
    var type = node.getAttribute('type') || '';
    var name = node.getAttribute('name') || '';
    var href = node.getAttribute('href') || '';
    var id = node.getAttribute('id') || '';
    var classes = node.className && typeof node.className === 'string' ? node.className.trim() : '';
    var active = (node.classList && node.classList.contains('active') || node.getAttribute('aria-selected') === 'true') ? ' [active]' : '';
    var disabled = node.disabled ? ' [disabled]' : '';
    var required = node.required ? ' [required]' : '';
    var rawText = (node.children && node.children.length === 0) ? (node.textContent ? node.textContent.trim().slice(0, 80) : '') : '';
    // Fallback: custom/server-side tags (e.g. <ntl:formatnumber value="...">) may render empty —
    // surface the `value` attribute so the number isn't lost in snapshots.
    var text = rawText || (tag.indexOf(':') !== -1 && node.getAttribute('value') ? node.getAttribute('value') : '');

    // Build tag identifier: tag#id.class1.class2
    var ident = tag;
    if (id) ident += '#' + id;
    if (classes) ident += '.' + classes.split(/\s+/).join('.');

    // Add ARIA role if different from implicit HTML role
    var line = '  '.repeat(depth) + ident;
    if (ariaRole) line += ' role="' + ariaRole + '"';
    if (label) line += ' aria-label="' + label + '"';
    else if (labelledBy) line += ' aria-labelledby="' + labelledBy + '"';
    if (text) line += ' "' + text + '"';
    if (name) line += ' name="' + name + '"';
    if (placeholder) line += ' placeholder="' + placeholder + '"';
    if (type) line += ' [' + type + ']';
    if (href && href !== '#') line += ' → ' + href;
    line += active + disabled + required + '\n';

    for (var c = 0; c < node.children.length; c++) {
      line += tree(node.children[c], depth + 1);
    }
    return line;
  }

  return tree(root);
};

// Backward-compatible aliases
window.__capture['snapshot-content'] = function(opts) {
  return window.__capture['snapshot'](opts);
};
window.__capture['snapshot-element'] = function(opts) {
  return window.__capture['snapshot'](opts);
};
