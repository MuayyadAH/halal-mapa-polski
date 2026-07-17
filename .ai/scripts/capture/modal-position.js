/**
 * Modal/panel position and styling detection.
 * Pure browser-side script — loaded via addScriptTag, never enters LLM context.
 *
 * Registers: window.__capture['modal-position'](opts)
 * Options:
 *   modalSelector    - CSS selector for the modal element (overrides built-in)
 *   backdropSelector - CSS selector for the backdrop element (overrides built-in)
 * Returns: JSON string with { modalBox, viewport, styles, backdropStyles, detection }
 *
 * Detection strategy (in order):
 *   1. Selector-based (scored) — querySelectorAll against framework patterns,
 *      scored to prefer dialog panels over backdrops
 *   2. CSS heuristic — scan visible positioned elements (z-index >= 10)
 *   3. Cross-frame — check parent frame for modal wrappers (Liferay iframes)
 *   4. Close-button heuristic — walk up from close buttons to find dialog container
 *   5. Backdrop-only — detect backdrop/overlay as evidence of modal intent
 */
window.__capture = window.__capture || {};
window.__capture['modal-position'] = function(opts) {
  opts = opts || {};

  // ── 1. Framework-aware modal selectors ──────────────────────────────────
  var modalSelector = opts.modalSelector || [
    // ARIA standard
    '[role="dialog"]',
    '[role="alertdialog"]',
    '[aria-modal="true"]',
    'dialog[open]',

    // Angular Material / CDK
    'mat-dialog-container',
    '.mat-mdc-dialog-container',
    '.cdk-overlay-pane:not(:empty)',

    // React MUI
    '.MuiDialog-root',
    '.MuiModal-root',
    '.MuiDrawer-root',

    // Bootstrap (3, 4, 5)
    '.modal.show',
    '.modal.in',
    '.modal-dialog',

    // Ant Design
    '.ant-modal-wrap',
    '.ant-modal',
    '.ant-drawer',

    // Chakra UI
    '.chakra-modal__content',
    '.chakra-modal__overlay',

    // Headless UI / Radix / shadcn
    '[data-headlessui-state*="open"]',
    '[data-state="open"][role="dialog"]',
    '[data-radix-dialog-content]',

    // PrimeNG / PrimeFaces / PrimeReact
    '.p-dialog',
    '.p-sidebar',
    '.ui-dialog',

    // Vuetify
    '.v-dialog',
    '.v-dialog--active',
    '.v-overlay--active',

    // Semantic UI
    '.ui.modal.visible',
    '.ui.modal.active',

    // Kendo UI
    '.k-dialog',
    '.k-window',
    '.k-animation-container',

    // DevExtreme
    '.dx-popup-wrapper',
    '.dx-overlay-wrapper',

    // Telerik
    '.rwWindowContent',
    '.RadWindow',

    // Liferay / AlloyUI / YUI / Clay
    '.aui-dialog',
    '.aui-dialog-bd',
    '.aui-modal',
    '.aui-panel',
    '.yui3-panel',
    '.yui3-widget-modal',
    '.yui-panel',
    '.liferay-modal',
    '.dialog-iframe-popup',
    '.lfr-alert-dialog',
    '.lfr-dynamic-popup',
    '.lfr-form-popup',
    '.lfr-popup',
    '.portlet-msg-alert',
    '.portlet-item-selector-dialog',
    '.clay-modal',
    '.cadmin .modal',
    '[data-dismiss="modal"]',
    '[data-bs-dismiss="modal"]',

    // jQuery UI
    '.ui-dialog',
    '.ui-dialog-content',

    // ExtJS / Sencha
    '.x-window',
    '.x-panel-floating',
    '.x-mask',

    // Dojo / Dijit
    '.dijitDialog',
    '.dijitDialogPaneContent',

    // Vaadin
    'vaadin-dialog-overlay',
    '[overlay-id]',

    // SAP UI5 / OpenUI5
    '.sapMDialog',
    '.sapMDialogOpen',
    '.sapUiDlg',

    // ICEfaces / RichFaces
    '.ice-modal-dialog',
    '.rf-pp-cntr',
    '.rich-mpnl-content',

    // GWT
    '.gwt-PopupPanelGlass + .gwt-PopupPanel',
    '.gwt-DialogBox',

    // Generic patterns (last resort)
    '[class*="modal"]',
    '[class*="Modal"]',
    '[class*="dialog"]',
    '[class*="Dialog"]',
    '[class*="drawer"]',
    '[class*="Drawer"]',
    '[class*="popup"]',
    '[class*="Popup"]',
    '[class*="lightbox"]',
    '[class*="Lightbox"]'
  ].join(', ');

  // ── 2. Framework-aware backdrop selectors ───────────────────────────────
  var backdropSelector = opts.backdropSelector || [
    // Angular Material / CDK
    '.cdk-overlay-backdrop',
    '.cdk-overlay-dark-backdrop',

    // React MUI
    '.MuiBackdrop-root',

    // Bootstrap
    '.modal-backdrop',

    // Ant Design
    '.ant-modal-mask',
    '.ant-drawer-mask',

    // Chakra UI
    '.chakra-modal__overlay',

    // PrimeNG / PrimeFaces
    '.p-dialog-mask',
    '.ui-widget-overlay',

    // Vuetify
    '.v-overlay__scrim',

    // Kendo UI
    '.k-overlay',

    // DevExtreme
    '.dx-overlay-shader',

    // Liferay / AlloyUI / YUI
    '.aui-mask',
    '.yui3-widget-mask',
    '.portal-popup-mask',

    // jQuery UI
    '.ui-widget-overlay',
    '.ui-front',

    // ExtJS
    '.x-mask',

    // SAP UI5
    '.sapUiBLy',

    // ICEfaces / RichFaces
    '.rf-pp-shade',
    '.ice-modal-mask',

    // GWT
    '.gwt-PopupPanelGlass',

    // Generic patterns
    '[class*="backdrop"]',
    '[class*="Backdrop"]',
    '[class*="overlay"]',
    '[class*="Overlay"]',
    '[class*="mask"]',
    '[class*="Mask"]',
    '#overlay',
    '[id*="backdrop"]',
    '[id*="Backdrop"]'
  ].join(', ');

  var vw = window.innerWidth;
  var vh = window.innerHeight;

  // ── Helper: full-viewport element = likely a backdrop, not the dialog ──
  function isLikelyBackdrop(el) {
    var r = el.getBoundingClientRect();
    return r.width >= vw * 0.9 && r.height >= vh * 0.9;
  }

  // ── 3. Selector-based detection (scored to avoid picking backdrops) ────
  // querySelectorAll + scoring instead of querySelector (which just returns
  // the first DOM-order match — often the backdrop element).
  var modal = null;
  var detection = 'selector';

  var allMatches = document.querySelectorAll(modalSelector);
  if (allMatches.length > 0) {
    var bestSelScore = -Infinity;
    for (var si = 0; si < allMatches.length; si++) {
      var sel = allMatches[si];
      var scs = window.getComputedStyle(sel);
      if (scs.display === 'none' || scs.visibility === 'hidden') continue;
      var sr = sel.getBoundingClientRect();
      if (sr.width === 0 || sr.height === 0) continue;

      var sScore = 0;
      // Penalize full-viewport elements (backdrops)
      if (isLikelyBackdrop(sel)) sScore -= 10000;
      // Reward interactive content (buttons, inputs, tables, headings, links)
      var childCount = sel.querySelectorAll(
        'button, input, table, form, h1, h2, h3, a, select, textarea'
      ).length;
      sScore += Math.min(childCount, 20) * 100;
      // Factor in z-index
      var sz = parseInt(scs.zIndex, 10);
      if (!isNaN(sz)) sScore += sz;
      // Bonus for centered elements
      var scx = Math.abs((sr.left + sr.width / 2) - vw / 2);
      var scy = Math.abs((sr.top + sr.height / 2) - vh / 2);
      sScore += (1 - (scx + scy) / (vw + vh)) * 50;

      if (sScore > bestSelScore) {
        bestSelScore = sScore;
        modal = sel;
      }
    }
    // Reject if the best match is just a backdrop with no real content
    if (modal && isLikelyBackdrop(modal) && bestSelScore < -5000) modal = null;
  }

  // ── 4. CSS heuristic fallback ───────────────────────────────────────────
  // When no selector matches, scan visible elements for modal-like CSS:
  //   - position: fixed or absolute
  //   - z-index >= 10  (lowered — some frameworks use low z-index values)
  //   - covers significant viewport area (>= 20% width AND >= 20% height)
  //   - currently visible (display !== none, visibility !== hidden)
  if (!modal) {
    detection = 'css-heuristic';
    var bestScore = 0;
    var candidates = document.querySelectorAll('*');

    for (var i = 0; i < candidates.length; i++) {
      var el = candidates[i];
      var cs = window.getComputedStyle(el);
      var pos = cs.position;
      if (pos !== 'fixed' && pos !== 'absolute') continue;
      if (cs.display === 'none' || cs.visibility === 'hidden') continue;

      var z = parseInt(cs.zIndex, 10);
      if (isNaN(z) || z < 10) continue;

      var r = el.getBoundingClientRect();
      if (r.width < vw * 0.2 || r.height < vh * 0.2) continue;

      // Skip full-viewport elements (likely backdrops, not the modal itself)
      if (r.width >= vw * 0.95 && r.height >= vh * 0.95) continue;

      // Score: prefer higher z-index and more centered elements
      var centerX = Math.abs((r.left + r.width / 2) - vw / 2);
      var centerY = Math.abs((r.top + r.height / 2) - vh / 2);
      var centeredness = 1 - ((centerX + centerY) / (vw + vh));
      var score = z * centeredness;

      if (score > bestScore) {
        bestScore = score;
        modal = el;
      }
    }
  }

  // ── 4.5. Cross-frame detection (iframe-embedded portlets) ─────────────
  // Liferay portlets often run inside iframes while the modal wrapper lives
  // in the parent frame. Check parent frame (same-origin only).
  if (!modal && window.parent !== window) {
    try {
      var parentDoc = window.parent.document;
      var pMatches = parentDoc.querySelectorAll(modalSelector);
      for (var pi = 0; pi < pMatches.length; pi++) {
        var pel = pMatches[pi];
        var ppcs = window.parent.getComputedStyle(pel);
        if (ppcs.display === 'none' || ppcs.visibility === 'hidden') continue;
        var pr = pel.getBoundingClientRect();
        if (pr.width === 0 || pr.height === 0) continue;
        var pvw = window.parent.innerWidth;
        var pvh = window.parent.innerHeight;
        if (pr.width >= pvw * 0.9 && pr.height >= pvh * 0.9) continue; // skip backdrops

        // Found modal in parent frame — extract styles and return immediately
        // (cannot mix cross-frame elements with later getComputedStyle calls)
        var pBackdrop = parentDoc.querySelector(backdropSelector);
        var pBackdropStyles = null;
        if (pBackdrop) {
          var pbcs = window.parent.getComputedStyle(pBackdrop);
          pBackdropStyles = {
            tagName: pBackdrop.tagName.toLowerCase(),
            classes: Array.from(pBackdrop.classList).slice(0, 10),
            backgroundColor: pbcs.backgroundColor, opacity: pbcs.opacity,
            position: pbcs.position, zIndex: pbcs.zIndex
          };
        }
        return JSON.stringify({
          type: 'modal', detection: 'parent-frame',
          modalBox: { x: pr.x, y: pr.y, width: pr.width, height: pr.height },
          viewport: { width: pvw, height: pvh },
          styles: {
            tagName: pel.tagName.toLowerCase(),
            classes: Array.from(pel.classList).slice(0, 10),
            position: ppcs.position,
            top: ppcs.top, right: ppcs.right, bottom: ppcs.bottom, left: ppcs.left,
            width: ppcs.width, height: ppcs.height, maxWidth: ppcs.maxWidth,
            zIndex: ppcs.zIndex, display: ppcs.display, transform: ppcs.transform,
            margin: ppcs.margin, borderRadius: ppcs.borderRadius,
            boxShadow: ppcs.boxShadow, backgroundColor: ppcs.backgroundColor,
            rect: { left: pr.left, right: pr.right, top: pr.top, width: pr.width, height: pr.height }
          },
          backdropStyles: pBackdropStyles
        });
      }
    } catch (e) { /* cross-origin — skip parent frame */ }
  }

  // ── 4.6. Close-button heuristic ───────────────────────────────────────
  // A close button is a strong signal of a dialog/popup.
  // Walk up from the close button to find the positioned container.
  if (!modal) {
    var closeBtns = document.querySelectorAll(
      'button[aria-label="Close"], button[aria-label="close"],' +
      'button.close, .btn-close, [data-dismiss="modal"], [data-bs-dismiss="modal"],' +
      'a.close, .modal-close, .dialog-close'
    );
    for (var ci = 0; ci < closeBtns.length; ci++) {
      var closeBtn = closeBtns[ci];
      var cbcs = window.getComputedStyle(closeBtn);
      if (cbcs.display === 'none' || cbcs.visibility === 'hidden') continue;
      // Walk up to find positioned container (max 15 levels)
      var container = closeBtn.parentElement;
      for (var lvl = 0; lvl < 15 && container && container !== document.body; lvl++) {
        var ccs = window.getComputedStyle(container);
        var cpos = ccs.position;
        if (cpos === 'fixed' || cpos === 'absolute') {
          var cr = container.getBoundingClientRect();
          if (cr.width >= vw * 0.15 && cr.height >= vh * 0.15 && !isLikelyBackdrop(container)) {
            modal = container;
            detection = 'close-button';
            break;
          }
        }
        container = container.parentElement;
      }
      if (modal) break;
    }
  }

  if (!modal) {
    // ── 5. Backdrop-only fallback ───────────────────────────────────────
    // Check if a backdrop exists even without a detected modal panel.
    // This catches cases where the "modal" is just an inline div
    // but a backdrop overlay IS present, confirming modal intent.
    var backdropOnly = document.querySelector(backdropSelector);
    if (!backdropOnly) {
      // Also scan for backdrop via CSS heuristic
      var allEls = document.querySelectorAll('*');
      for (var j = 0; j < allEls.length; j++) {
        var bel = allEls[j];
        var bcs = window.getComputedStyle(bel);
        if (bcs.position !== 'fixed' && bcs.position !== 'absolute') continue;
        if (bcs.display === 'none' || bcs.visibility === 'hidden') continue;
        var br = bel.getBoundingClientRect();
        // Backdrop = nearly full viewport coverage
        if (br.width < window.innerWidth * 0.9 || br.height < window.innerHeight * 0.9) continue;
        var bgc = bcs.backgroundColor;
        var op = parseFloat(bcs.opacity);
        // Semi-transparent or has rgba with alpha < 1
        var hasAlpha = bgc.indexOf('rgba') >= 0 && parseFloat(bgc.split(',')[3]) < 1;
        if (op < 1 || hasAlpha) {
          backdropOnly = bel;
          break;
        }
      }
    }
    if (backdropOnly) {
      var bbcs = window.getComputedStyle(backdropOnly);
      return JSON.stringify({
        type: 'modal-intent',
        detection: 'backdrop-only',
        reason: 'No modal panel found but backdrop/overlay detected — likely a modal with non-standard markup',
        backdropStyles: {
          tagName: backdropOnly.tagName.toLowerCase(),
          classes: Array.from(backdropOnly.classList).slice(0, 10),
          backgroundColor: bbcs.backgroundColor,
          opacity: bbcs.opacity,
          backdropFilter: bbcs.backdropFilter,
          position: bbcs.position,
          display: bbcs.display,
          zIndex: bbcs.zIndex
        }
      });
    }

    return JSON.stringify({ type: 'unknown', reason: 'No modal element or backdrop found by selector or CSS heuristic' });
  }

  // ── 6. Extract modal styles ─────────────────────────────────────────────
  var rect = modal.getBoundingClientRect();
  var modalBox = { x: rect.x, y: rect.y, width: rect.width, height: rect.height };
  var viewport = { width: window.innerWidth, height: window.innerHeight };

  var mcs = window.getComputedStyle(modal);
  var styles = {
    tagName: modal.tagName.toLowerCase(),
    classes: Array.from(modal.classList).slice(0, 10),
    position: mcs.position,
    top: mcs.top, right: mcs.right, bottom: mcs.bottom, left: mcs.left,
    width: mcs.width, height: mcs.height, maxWidth: mcs.maxWidth,
    zIndex: mcs.zIndex,
    display: mcs.display,
    transform: mcs.transform,
    margin: mcs.margin,
    borderRadius: mcs.borderRadius,
    boxShadow: mcs.boxShadow,
    backgroundColor: mcs.backgroundColor,
    rect: { left: rect.left, right: rect.right, top: rect.top, width: rect.width, height: rect.height }
  };

  // ── 7. Extract backdrop styles ──────────────────────────────────────────
  var backdropStyles = null;
  var backdrop = document.querySelector(backdropSelector);
  if (backdrop) {
    var bcs2 = window.getComputedStyle(backdrop);
    backdropStyles = {
      tagName: backdrop.tagName.toLowerCase(),
      classes: Array.from(backdrop.classList).slice(0, 10),
      backgroundColor: bcs2.backgroundColor,
      opacity: bcs2.opacity,
      backdropFilter: bcs2.backdropFilter,
      position: bcs2.position,
      display: bcs2.display,
      zIndex: bcs2.zIndex,
      alignItems: bcs2.alignItems,
      justifyContent: bcs2.justifyContent
    };
  }

  return JSON.stringify({
    type: 'modal',
    detection: detection,
    modalBox: modalBox,
    viewport: viewport,
    styles: styles,
    backdropStyles: backdropStyles
  });
};
