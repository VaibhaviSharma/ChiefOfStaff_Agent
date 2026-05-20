#!/usr/bin/env bash
# Olive — Slack Ingestion Agent
# Runs hourly on weekdays, scans DMs + @mentions, writes to pending.md

export HOME="/Users/yourname"
export PATH="/Users/yourname/.local/bin:/usr/local/bin:/usr/bin:/bin"

CLAUDE="/Users/yourname/.local/bin/claude"
LOG="/Users/yourname/.olive/logs/ingestion.log"

echo "[$(date)] Olive ingestion starting" >> "$LOG"

"$CLAUDE" --print \
  --allowedTools "Bash,Read,Write,Edit" \
  <<'EOF' >> "$LOG" 2>&1
You are Olive, Vaibhavi's Chief of Staff agent. Read ~/.olive/CLAUDE.md for your full instructions before starting.

Task: SLACK INGESTION RUN

Use the Bash tool to call `python3 ~/.olive/slack_api.py` for all Slack operations:
  - Search: python3 ~/.olive/slack_api.py search "<query>"
  - Send DM: echo "<message>" | python3 ~/.olive/slack_api.py send YOUR_SLACK_USER_ID
  - Read thread: python3 ~/.olive/slack_api.py thread <channel_id> <ts>

Steps:
1. Check the current day and time: run `date`. If it is a weekend (Saturday or Sunday) or outside 7am-8pm PT, print 'Skipping: outside work hours' and stop.
2. Read ~/.olive/state.json. Note ingestion.last_slack_ts (may be null on first run).
3. Search Slack for new messages:
   - Search 1: python3 ~/.olive/slack_api.py search "<@YOUR_SLACK_USER_ID>"
   - Search 2: python3 ~/.olive/slack_api.py search "from:YOUR_SLACK_USER_ID"
   Filter to only messages newer than last_slack_ts (compare the ts field). If last_slack_ts is null, use all results from the past 2 hours (ts > current_unix_time - 7200).
4. For each new message found, extract:
   - Action items (tasks Vaibhavi is asked to do, or committed to)
   - Any deadlines mentioned
   - Workstream context (project name, recurring participants, channel name)
5. If items were extracted:
   a. Append them to ~/.olive/pending.md in the existing table format (Task | Workstream | Deadline | Source)
   b. Update ~/.olive/workstreams.md if any new workstreams are identified
   c. Send a Slack DM: echo "I found [N] new item(s) for your review. Run \`olive approve\` to add them to your list. — Olive 🫒" | python3 ~/.olive/slack_api.py send YOUR_SLACK_USER_ID
6. Update ~/.olive/state.json: set ingestion.last_run to current ISO timestamp and ingestion.last_slack_ts to the most recent message ts seen.
7. If no new items found, still update state.json but send no DM. Print 'No new items found.'
EOF

echo "[$(date)] Olive ingestion done" >> "$LOG"
