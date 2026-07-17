#!/usr/bin/env node
// Claude Code Statusline - AI1st Edition
// Shows: AI1st | branch | context usage | duration

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

// Read JSON from stdin
let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const model = data.model?.display_name || 'Claude';
    const dir = data.workspace?.current_dir || process.cwd();
    const session = data.session_id || '';
    const remaining = data.context_window?.remaining_percentage;
    const durationMs = data.cost?.total_duration_ms || 0;

    // Context window display (shows USED percentage scaled to 80% limit)
    let ctx = '';
    if (remaining != null) {
      const rem = Math.round(remaining);
      const rawUsed = Math.max(0, Math.min(100, 100 - rem));
      const used = Math.min(100, Math.round((rawUsed / 80) * 100));

      // Write context metrics to bridge file for the context-monitor hook
      if (session) {
        try {
          const bridgePath = path.join(os.tmpdir(), `claude-ctx-${session}.json`);
          const bridgeData = JSON.stringify({
            session_id: session,
            remaining_percentage: remaining,
            used_pct: used,
            timestamp: Math.floor(Date.now() / 1000)
          });
          fs.writeFileSync(bridgePath, bridgeData);
        } catch (e) {
          // Silent fail -- bridge is best-effort
        }
      }

      // Build progress bar (10 segments)
      const filled = Math.floor(used / 10);
      const bar = '\u2588'.repeat(filled) + '\u2591'.repeat(10 - filled);

      // Color based on scaled usage
      if (used < 63) {
        ctx = ` \x1b[32m${bar} ${used}%\x1b[0m`;
      } else if (used < 81) {
        ctx = ` \x1b[33m${bar} ${used}%\x1b[0m`;
      } else if (used < 90) {
        ctx = ` \x1b[38;5;208m${bar} ${used}%\x1b[0m`;
      } else if (used < 95) {
        ctx = ` \u{1F7E1} \x1b[33m${bar} ${used}%\x1b[0m`;
      } else {
        ctx = ` \u{1F534} \x1b[5;31m${bar} ${used}%\x1b[0m`;
      }
    }

    // Git branch
    let branch = '';
    try {
      const branchName = execSync('git branch --show-current', {
        cwd: dir,
        encoding: 'utf8',
        timeout: 3000,
        stdio: ['pipe', 'pipe', 'pipe']
      }).trim();
      if (branchName) branch = branchName;
    } catch (e) {
      // Not a git repo or git not available
    }

    // Duration (compact: 2h15m or 5m)
    const totalMins = Math.floor(durationMs / 60000);
    const hours = Math.floor(totalMins / 60);
    const mins = totalMins % 60;
    const timeParts = [];
    if (hours > 0) timeParts.push(`${hours}h`);
    timeParts.push(`${mins}m`);
    // Output (single line)
    const logo = '\x1b[1;33mAI\x1b[0;33m1st\x1b[0m';
    const sep = ' \x1b[2m│\x1b[0m ';
    const parts = [logo, `\x1b[38;5;246m${model}\x1b[0m`];
    parts.push(`\x1b[1;38;5;110m\u2387\x1b[0;38;5;110m ${branch}\x1b[0m`);
    if (ctx) parts.push(ctx.trimStart());
    parts.push(`\x1b[38;5;246m\u23F1 ${timeParts.join('')}\x1b[0m`);

    process.stdout.write(parts.join(sep));
  } catch (e) {
    // Silent fail - don't break statusline on parse errors
  }
});
