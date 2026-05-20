# Olive — Chief of Staff Agent

Olive is a personal AI chief of staff that monitors your Slack, manages your to-do list, tracks workstreams, and sends smart deadline reminders. Built on Claude Code and the Slack MCP.

---

## What Olive Does

| Capability | Description |
|---|---|
| **Morning Briefing** | Sends a daily Slack DM at 8:30am PT with prioritized to-dos, deadlines, and pending approvals |
| **Slack Ingestion** | Scans DMs and @mentions, extracts action items, and queues them for approval |
| **Deadline Reminders** | Escalating reminders based on urgency — from weekly mentions to same-day alerts |
| **Approval Workflow** | Nothing lands in your to-do list without your sign-off (`olive approve`) |
| **Workstream Tracking** | Infers recurring projects from Slack context and keeps them updated |

---

## How It Works

Olive runs as three scheduled shell agents via cron:

```
agents/
  briefing.sh    — morning briefing (8:30am PT weekdays)
  ingestion.sh   — Slack scan and action item extraction
  deadline.sh    — deadline status checks and escalations
```

All state is stored locally in `~/.olive/`:

```
~/.olive/
  CLAUDE.md         — Olive's identity and instructions
  config.json       — user settings and preferences
  state.json        — runtime state (last-run timestamps, open Slack threads)
  todos.md          — approved to-do list (source of truth)
  pending.md        — items awaiting approval
  workstreams.md    — inferred workstreams
  slack_api.py      — Slack API helper script
  logs/             — agent run logs
```

---

## Approval Workflow

Olive never adds items directly to your to-do list.

1. Olive scans Slack and extracts action items → `pending.md`
2. Olive sends you a Slack DM to notify you
3. You run `olive approve` to review and accept/reject each item
4. Approved items move to `todos.md`

---

## Deadline Reminder Logic

| Days Until Due | Action |
|---|---|
| 7+ days | Mention in morning briefing only |
| 3–6 days | Daily morning briefing mention |
| 2 days | Morning reminder + noon status check DM |
| 1 day | Morning high-priority + afternoon status check DM |
| Due today | Morning urgent flag + midday check if not done |
| Overdue | Morning escalation daily until resolved |

---

## Setup

### Prerequisites
- [Claude Code CLI](https://claude.ai/code) installed
- Slack MCP configured with workspace access
- `cron` or `launchd` for scheduling agents

### Installation

```bash
git clone https://github.com/VaibhaviSharma/ChiefOfStaff_Agent.git ~/.olive
cd ~/.olive
cp config.json.example config.json   # fill in your details
```

### Configure
Edit `config.json` with your Slack user ID, email, and timezone.

### Schedule Agents
Add to crontab (`crontab -e`):

```cron
30 8 * * 1-5  /Users/yourname/.olive/agents/briefing.sh
0  9 * * 1-5  /Users/yourname/.olive/agents/ingestion.sh
0 12 * * 1-5  /Users/yourname/.olive/agents/deadline.sh
```

---

## Commands

| Command | Description |
|---|---|
| `olive approve` | Review and approve pending Slack-extracted items |
| `olive todos` | View active to-do list |
| `olive done [#]` | Mark a to-do complete |

---

## Tech Stack

- **Claude Code** — agent runtime and reasoning
- **Slack MCP** — Slack read/write integration
- **Bash** — lightweight agent scheduling
- **Markdown** — human-readable state files
