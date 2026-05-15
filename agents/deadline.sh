#!/usr/bin/env bash
# Olive — Noon Deadline Checker Agent
# Runs 12:00pm PT on weekdays, sends urgency-based status check DMs

export HOME="/Users/yourname"
export PATH="/Users/yourname/.local/bin:/usr/local/bin:/usr/bin:/bin"

CLAUDE="/Users/yourname/.local/bin/claude"
LOG="/Users/yourname/.olive/logs/deadline.log"

echo "[$(date)] Olive deadline checker starting" >> "$LOG"

"$CLAUDE" --print \
  --allowedTools "mcp__slack__slack_send_message,Read,Write,Edit" \
  "You are Olive, Vaibhavi's Chief of Staff agent. Read ~/.olive/CLAUDE.md for your full instructions before starting.

Task: NOON DEADLINE CHECK

Steps:
1. Read ~/.olive/todos.md and ~/.olive/state.json.
2. Get today's date. Find all ACTIVE to-do items that have a deadline.
3. For items already tracked in state.json deadline_checker.open_threads, skip them (already pinged today).
4. For remaining items, calculate days_until_due and send a Slack DM to YOUR_SLACK_USER_ID per this logic:

   - Due in 2 days: 'Hey! \"[task]\" is due in 2 days. How is it going? Reply \"done\" if you've finished it. — Olive 🫒'
   - Due tomorrow: 'Quick heads up — \"[task]\" is due TOMORROW. Have you finished it? Reply \"done\" if complete. — Olive 🫒'
   - Due today: '🚨 \"[task]\" is due TODAY. Is it done? Reply \"done\" if complete. — Olive 🫒'
   - Overdue (1 day): '\"[task]\" was due yesterday. Did you complete it? Reply \"done\", \"reschedule YYYY-MM-DD\", or \"drop it\". — Olive 🫒'
   - Overdue (2+ days): '\"[task]\" is [N] days overdue. What is the status? Reply \"done\", \"reschedule YYYY-MM-DD\", or \"drop it\". — Olive 🫒'

5. For each DM sent, record in state.json deadline_checker.open_threads:
   {\"task\": \"[task name]\", \"thread_ts\": \"[ts from send response]\", \"channel\": \"[channel from send response]\", \"sent_at\": \"[ISO timestamp]\"}
6. Update state.json deadline_checker.last_run to current ISO timestamp.
7. If no items need checking, print 'No deadline checks needed today.' and update last_run only.
" >> "$LOG" 2>&1

echo "[$(date)] Olive deadline checker done" >> "$LOG"
