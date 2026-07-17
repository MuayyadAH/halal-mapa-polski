/**
 * Style & Icon Extraction — page-level or element-scoped.
 * Pure browser-side script — loaded via addScriptTag, never enters LLM context.
 *
 * Registers: window.__capture['styles'](opts)
 * Options:
 *   containerSelector - CSS selector to scope extraction (omit for full page)
 *   skipSelectors     - CSS selector for elements to skip (default: Liferay admin UI)
 * Returns: JSON string with { styles: [...], icons: [...], colors: [...] }
 *
 * Icon detection strategies:
 *   1. Inline SVG elements (<svg> in DOM)
 *   2. Font/class-based icons (Material, FA, Bootstrap, Lucide, etc.)
 *   3. CSS background-image icons (url() pointing to .svg/.png/.jpg etc.)
 */
window.__capture = window.__capture || {};
window.__capture['styles'] = function(opts) {
  opts = opts || {};
  var SKIP = opts.skipSelectors || '.cadmin, .portlet-topper, [class*="portlet-options"], nav[aria-label="Control Menu"], .lfr-product-menu-panel';

  // Determine scope: element container or full document
  var scoped = !!opts.containerSelector;
  var root;
  if (scoped) {
    root = document.querySelector(opts.containerSelector);
    if (!root) return JSON.stringify({ styles: [], icons: [], colors: [] });
  } else {
    root = document;
  }

  // Style selectors — page-level includes nav/header/aside, element-scoped does not
  var selectors = [
    'button, [role="button"]',
    '[class*="card"], [class*="panel"]',
    'h1, h2, h3, h4',
    'table, th, td, [role="grid"], [role="gridcell"]',
    'input, textarea, select, [role="textbox"], [role="combobox"]',
    '[class*="badge"], [class*="chip"], [class*="tag"], [class*="status"]',
    '[role="tab"], [role="tablist"], [role="tabpanel"]'
  ];
  if (!scoped) {
    selectors.push(
      'nav, [role="navigation"]',
      'header, [role="banner"]',
      'aside, [role="complementary"]',
      '[class*="tab"], [class*="Tab"]'
    );
  }

  var maxSamples = scoped ? 3 : 5;
  var maxClasses = scoped ? 3 : 5;
  var results = [];

  for (var i = 0; i < selectors.length; i++) {
    try {
      var elements = Array.from(root.querySelectorAll(selectors[i])).slice(0, maxSamples);
      for (var j = 0; j < elements.length; j++) {
        var el = elements[j];
        if (el.closest(SKIP)) continue;
        var cs = window.getComputedStyle(el);
        results.push({
          tagName: el.tagName.toLowerCase(),
          classes: Array.from(el.classList).slice(0, maxClasses),
          role: el.getAttribute('role'),
          colors: {
            color: cs.color,
            backgroundColor: cs.backgroundColor,
            borderColor: cs.borderColor
          },
          typography: {
            fontFamily: cs.fontFamily,
            fontSize: cs.fontSize,
            fontWeight: cs.fontWeight,
            lineHeight: cs.lineHeight
          },
          spacing: {
            padding: cs.padding,
            margin: cs.margin,
            gap: cs.gap
          },
          borders: {
            borderRadius: cs.borderRadius,
            borderWidth: cs.borderWidth
          },
          effects: {
            boxShadow: cs.boxShadow
          }
        });
      }
    } catch (e) { /* selector not found */ }
  }

  // --- Icon extraction ---
  var allIcons = [];
  var seen = new Map();

  var toFileName = function(ctx, idx) {
    if (!ctx || ctx === 'standalone' || ctx.trim() === '')
      return 'icon-' + (idx + 1);
    return ctx.replace(/([A-Z])/g, '-$1').toLowerCase()
      .replace(/[^a-z0-9-]/g, '-').replace(/-+/g, '-')
      .replace(/^-|-$/g, '').slice(0, 40);
  };

  // 1. Inline SVG icons
  root.querySelectorAll('svg').forEach(function(svg) {
    var w = parseInt(svg.getAttribute('width') || '0', 10);
    var h = parseInt(svg.getAttribute('height') || '0', 10);
    if (w > 48 || h > 48) return;

    var rect = svg.getBoundingClientRect();
    if (rect.width === 0 && rect.height === 0) return;

    if (svg.closest(SKIP)) return;

    var paths = Array.from(svg.querySelectorAll('path')).map(function(p) { return p.getAttribute('d') || ''; }).join('|');
    var fingerprint = paths || svg.innerHTML.trim();
    if (seen.has(fingerprint)) {
      seen.get(fingerprint).count++;
      return;
    }

    var parent = svg.closest('button, a, [role="button"], td, th, li');
    var context = 'standalone';
    if (parent) {
      context = parent.getAttribute('aria-label')
        || parent.getAttribute('title')
        || (parent.textContent ? parent.textContent.trim().slice(0, 40) : '')
        || '';
      if (!context && parent.getAttribute('onclick')) {
        var match = parent.getAttribute('onclick').match(/action=(\w+)/);
        if (match) context = match[1];
      }
    }

    var hasFill = svg.querySelector('[fill]:not([fill="none"]):not([fill="currentColor"])');
    var hasStroke = svg.querySelector('[stroke]:not([stroke="none"]):not([stroke="currentColor"])');
    var cleanContext = context ? context.replace(/\s+/g, ' ') : '';

    seen.set(fingerprint, {
      type: 'svg',
      context: cleanContext,
      suggestedFileName: toFileName(cleanContext, seen.size) + '.svg',
      width: svg.getAttribute('width'),
      height: svg.getAttribute('height'),
      viewBox: svg.getAttribute('viewBox'),
      style: hasFill ? 'fill' : hasStroke ? 'stroke' : 'unknown',
      fillColor: hasFill ? hasFill.getAttribute('fill') : null,
      strokeColor: hasStroke ? hasStroke.getAttribute('stroke') : null,
      outerHTML: svg.outerHTML,
      count: 1
    });
  });
  allIcons.push.apply(allIcons, Array.from(seen.values()));

  // 2. Font/class-based icons
  var fontIconPatterns = [
    { selector: '.material-icons, .material-icons-outlined, .material-icons-round, .material-icons-sharp, .material-symbols-outlined, .material-symbols-rounded, .material-symbols-sharp, mat-icon',
      library: 'material', nameFrom: 'text' },
    { selector: '.fa, .fas, .far, .fal, .fat, .fad, .fab',
      library: 'font-awesome', nameFrom: 'class', pattern: /\bfa-([\w-]+)/ },
    { selector: '[class*="bi-"]',
      library: 'bootstrap-icons', nameFrom: 'class', pattern: /\bbi-([\w-]+)/ },
    { selector: '.lucide, [class*="lucide-"], lucide-icon',
      library: 'lucide', nameFrom: 'class', pattern: /\blucide-([\w-]+)/ },
    { selector: '[data-feather]',
      library: 'feather', nameFrom: 'attr', attr: 'data-feather' },
    { selector: '.ph, [class*="ph-"]',
      library: 'phosphor', nameFrom: 'class', pattern: /\bph-([\w-]+)/ },
    { selector: '.ti, [class*="ti-"]',
      library: 'tabler', nameFrom: 'class', pattern: /\bti-([\w-]+)/ },
    { selector: 'ion-icon',
      library: 'ionicons', nameFrom: 'attr', attr: 'name' },
    { selector: '[class*="ri-"]',
      library: 'remix', nameFrom: 'class', pattern: /\bri-([\w-]+)/ }
  ];

  var fontSeen = new Map();
  for (var p = 0; p < fontIconPatterns.length; p++) {
    var pat = fontIconPatterns[p];
    try {
      root.querySelectorAll(pat.selector).forEach(function(el) {
        var rect = el.getBoundingClientRect();
        if (rect.width === 0 && rect.height === 0) return;

        var name = '';
        if (pat.nameFrom === 'text') {
          name = el.textContent ? el.textContent.trim() : '';
          if (el.querySelector('svg')) return;
        } else if (pat.nameFrom === 'class' && pat.pattern) {
          var match = el.className.match(pat.pattern);
          name = match ? match[1] : '';
        } else if (pat.nameFrom === 'attr' && pat.attr) {
          name = el.getAttribute(pat.attr) || '';
        }
        if (!name) return;

        var key = pat.library + ':' + name;
        if (fontSeen.has(key)) {
          fontSeen.get(key).count++;
          return;
        }

        var cs = window.getComputedStyle(el);
        var parent = el.closest('button, a, [role="button"], td, th, li');
        var context = 'standalone';
        if (parent) {
          context = parent.getAttribute('aria-label')
            || parent.getAttribute('title')
            || '';
        }

        fontSeen.set(key, {
          type: 'font',
          library: pat.library,
          name: name,
          context: context ? context.replace(/\s+/g, ' ') : '',
          color: cs.color,
          fontSize: cs.fontSize,
          count: 1
        });
      });
    } catch (e) { /* selector not found */ }
  }
  allIcons.push.apply(allIcons, Array.from(fontSeen.values()));

  // 3. CSS background-image icons (common in legacy portals/CMS themes)
  var bgSeen = new Map();
  var bgCandidates = 'a, button, span, i, div, p, [role="button"], [role="img"]';
  try {
    root.querySelectorAll(bgCandidates).forEach(function(el) {
      if (el.closest(SKIP)) return;
      // Only consider small elements likely to be icons (max 64x64)
      var rect = el.getBoundingClientRect();
      if (rect.width === 0 && rect.height === 0) return;
      if (rect.width > 64 || rect.height > 64) return;
      // Skip elements with substantial text content (not icon-like)
      var text = (el.textContent || '').trim();
      if (text.length > 2) return;
      // Skip if element already contains an inline SVG or font icon
      if (el.querySelector('svg')) return;

      var cs = window.getComputedStyle(el);
      var bgImg = cs.backgroundImage;
      if (!bgImg || bgImg === 'none') return;

      // Extract url(...) value
      var urlMatch = bgImg.match(/url\(["']?([^"')]+)["']?\)/);
      if (!urlMatch) return;
      var url = urlMatch[1];

      // Only image files (svg, png, jpg, gif, webp, ico)
      if (!/\.(svg|png|jpe?g|gif|webp|ico)(\?|$)/i.test(url)) return;

      // Deduplicate by URL
      if (bgSeen.has(url)) {
        bgSeen.get(url).count++;
        return;
      }

      var parent = el.closest('button, a, [role="button"], td, th, li') || el;
      var context = parent.getAttribute('aria-label')
        || parent.getAttribute('title')
        || '';
      if (!context && parent.getAttribute('onclick')) {
        var match = parent.getAttribute('onclick').match(/(\w+)\(/);
        if (match) context = match[1];
      }
      var cleanContext = context ? context.replace(/\s+/g, ' ') : '';

      // Extract filename from URL for suggested name
      var fileMatch = url.match(/\/([^/?]+)(\?|$)/);
      var fileName = fileMatch ? fileMatch[1] : '';

      bgSeen.set(url, {
        type: 'css-background',
        context: cleanContext,
        suggestedFileName: fileName || toFileName(cleanContext, bgSeen.size + seen.size),
        sourceUrl: url,
        delivery: 'CSS background-image on ' + el.tagName.toLowerCase() +
          (el.className ? '.' + Array.from(el.classList).join('.') : ''),
        dimensions: Math.round(rect.width) + 'x' + Math.round(rect.height),
        count: 1
      });
    });
  } catch (e) { /* background-image scan failed */ }
  allIcons.push.apply(allIcons, Array.from(bgSeen.values()));

  // --- Element color extraction (grouped by unique color value) ---
  // Helper: convert rgb(r,g,b) to #hex
  var rgbToHex = function(rgb) {
    if (!rgb || rgb === 'rgba(0, 0, 0, 0)') return null;
    var m = rgb.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
    if (!m) return null;
    return '#' + ((1 << 24) + (parseInt(m[1]) << 16) + (parseInt(m[2]) << 8) + parseInt(m[3]))
      .toString(16).slice(1).toUpperCase();
  };

  var textColorMap = {};   // rgb -> { hex, usedBy: [{tag, sampleText, fontSize, fontWeight}], count }
  var bgColorMap = {};     // rgb -> { hex, usedBy: [{tag, sampleText}], count }
  var borderColorMap = {}; // rgb -> { hex, usedBy: [{tag}], count }

  var colorElements = (scoped ? root : document.body).querySelectorAll('*');
  for (var ci = 0; ci < colorElements.length; ci++) {
    var cel = colorElements[ci];
    if (cel.closest(SKIP)) continue;
    var rect = cel.getBoundingClientRect();
    if (rect.width === 0 && rect.height === 0) continue;
    var ccs = window.getComputedStyle(cel);
    var ctag = cel.tagName.toLowerCase();

    // Get direct text content (not from children)
    var ctext = '';
    for (var cn = 0; cn < cel.childNodes.length; cn++) {
      if (cel.childNodes[cn].nodeType === 3) {
        var ct = cel.childNodes[cn].textContent.trim();
        if (ct) { ctext = ct.substring(0, 40); break; }
      }
    }

    var ccolor = ccs.color;
    var cbg = ccs.backgroundColor;
    var cborder = ccs.borderTopColor || ccs.borderColor;

    // Group text colors
    if (ccolor && ccolor !== 'rgba(0, 0, 0, 0)') {
      if (!textColorMap[ccolor]) {
        textColorMap[ccolor] = { rgb: ccolor, hex: rgbToHex(ccolor), usedBy: [], count: 0 };
      }
      var tcEntry = textColorMap[ccolor];
      tcEntry.count++;
      // Track unique tag+fontSize+fontWeight combos (limit samples)
      var tcKey = ctag + '|' + ccs.fontSize + '|' + ccs.fontWeight;
      var tcExists = tcEntry.usedBy.some(function(u) { return u._key === tcKey; });
      if (!tcExists && tcEntry.usedBy.length < 8) {
        tcEntry.usedBy.push({
          _key: tcKey,
          tag: ctag,
          sampleText: ctext || null,
          fontSize: ccs.fontSize,
          fontWeight: ccs.fontWeight
        });
      }
    }

    // Group background colors
    if (cbg && cbg !== 'rgba(0, 0, 0, 0)') {
      if (!bgColorMap[cbg]) {
        bgColorMap[cbg] = { rgb: cbg, hex: rgbToHex(cbg), usedBy: [], count: 0 };
      }
      var bgEntry = bgColorMap[cbg];
      bgEntry.count++;
      var bgKey = ctag;
      var bgExists = bgEntry.usedBy.some(function(u) { return u.tag === bgKey; });
      if (!bgExists && bgEntry.usedBy.length < 6) {
        bgEntry.usedBy.push({ tag: ctag, sampleText: ctext || null });
      }
    }

    // Group border colors
    if (cborder && cborder !== 'rgba(0, 0, 0, 0)' && cborder !== ccolor) {
      if (!borderColorMap[cborder]) {
        borderColorMap[cborder] = { rgb: cborder, hex: rgbToHex(cborder), usedBy: [], count: 0 };
      }
      var bcEntry = borderColorMap[cborder];
      bcEntry.count++;
      var bcExists = bcEntry.usedBy.some(function(u) { return u.tag === ctag; });
      if (!bcExists && bcEntry.usedBy.length < 6) {
        bcEntry.usedBy.push({ tag: ctag });
      }
    }
  }

  // Clean up _key from usedBy before output
  var cleanUsedBy = function(map) {
    var arr = [];
    for (var rgb in map) {
      var entry = map[rgb];
      entry.usedBy = entry.usedBy.map(function(u) {
        var clean = { tag: u.tag };
        if (u.sampleText) clean.sampleText = u.sampleText;
        if (u.fontSize) clean.fontSize = u.fontSize;
        if (u.fontWeight) clean.fontWeight = u.fontWeight;
        return clean;
      });
      arr.push(entry);
    }
    // Sort by count descending
    arr.sort(function(a, b) { return b.count - a.count; });
    return arr;
  };

  var colorGroups = {
    textColors: cleanUsedBy(textColorMap),
    bgColors: cleanUsedBy(bgColorMap),
    borderColors: cleanUsedBy(borderColorMap)
  };

  return JSON.stringify({ styles: results, icons: allIcons, colors: colorGroups }, null, 2);
};

// Backward-compatible aliases
window.__capture['page-styles'] = function(opts) {
  return window.__capture['styles'](opts);
};
window.__capture['element-styles'] = function(opts) {
  return window.__capture['styles'](opts);
};
