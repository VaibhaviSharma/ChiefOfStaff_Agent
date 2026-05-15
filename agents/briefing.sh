#!/usr/bin/env bash
# Olive — Morning Briefing Agent
# Runs 8:30am PT on weekdays

export HOME="/Users/yourname"
export PATH="/Users/yourname/.local/bin:/usr/local/bin:/usr/bin:/bin"

CLAUDE="/Users/yourname/.local/bin/claude"
LOG="/Users/yourname/.olive/logs/briefing.log"

echo "[$(date)] Olive morning briefing starting" >> "$LOG"

"$CLAUDE" --print \
  --allowedTools "mcp__slack__slack_send_message,mcp__slack__slack_read_thread,Read,Write,Edit" \
  "You are Olive, Vaibhavi's Chief of Staff agent. Read ~/.olive/CLAUDE.md for your full instructions before starting.

Task: MORNING BRIEFING

Steps:
1. Read ~/.olive/todos.md and ~/.olive/state.json.
2. Process open status-check threads from state.json deadline_checker.open_threads:
   - For each entry, use slack_read_thread to check if Vaibhavi replied with 'done', 'yes', 'completed', 'finished', or similar
   - If yes: mark that to-do as complete in todos.md (move to Completed section with today's date), remove from open_threads in state.json
3. Read ~/.olive/pending.md. Count pending approval items.
4. For each active to-do with a deadline, calculate days_until_due from today.
5. Send a Slack DM to YOUR_SLACK_USER_ID with this exact structure:

Good morning, Vaibhavi! Here's your day at a glance ☀️

🔴 Due today or overdue:
[list items with deadline, or 'None']

🟠 Due in 1–2 days:
[list items, or 'None']

🟡 Due this week (3–6 days):
[list items, or 'None']

📋 [N] active to-dos | [N] awaiting your approval in pending.md

Run \`olive todos\` for the full list or \`olive approve\` to review pending items.

— Olive 🫒

6. Update state.json briefing.last_run to current ISO timestamp.
" >> "$LOG" 2>&1

echo "[$(date)] Olive morning briefing done" >> "$LOG"
