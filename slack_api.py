#!/usr/bin/env python3
"""Slack Web API helper for Olive background agents.
Usage:
  slack_api.py search <query>
  slack_api.py send <user_id>          (reads message from stdin)
  slack_api.py thread <channel> <ts>
  slack_api.py history <channel> [oldest_ts]
"""
import sys
import json
import urllib.request
import urllib.parse
import os

def _token():
    cfg = os.path.expanduser("~/.olive/slack-mcp.json")
    with open(cfg) as f:
        d = json.load(f)
    return d["mcpServers"]["slack"]["headers"]["Authorization"].replace("Bearer ", "")

def _call(method, params, get=False):
    token = _token()
    if get:
        qs = "&".join(f"{k}={urllib.parse.quote(str(v))}" for k, v in params.items())
        url = f"https://slack.com/api/{method}?{qs}"
        req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
    else:
        url = f"https://slack.com/api/{method}"
        data = json.dumps(params).encode()
        req = urllib.request.Request(url, data=data, headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        })
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read())

def search(query):
    res = _call("search.messages", {"query": query, "count": 30, "sort": "timestamp", "sort_dir": "desc"}, get=True)
    if not res.get("ok"):
        sys.exit(f"search error: {res.get('error')}")
    matches = res.get("messages", {}).get("matches", [])
    return [{"ts": m["ts"], "text": m["text"],
             "channel": m.get("channel", {}).get("id"),
             "channel_name": m.get("channel", {}).get("name"),
             "user": m.get("user"), "permalink": m.get("permalink")} for m in matches]

def send(user_id, text):
    ch = _call("conversations.open", {"users": user_id})
    if not ch.get("ok"):
        sys.exit(f"open DM error: {ch.get('error')}")
    channel_id = ch["channel"]["id"]
    res = _call("chat.postMessage", {"channel": channel_id, "text": text})
    if not res.get("ok"):
        sys.exit(f"send error: {res.get('error')}")
    return {"channel": res["channel"], "ts": res["ts"]}

def thread(channel, ts):
    res = _call("conversations.replies", {"channel": channel, "ts": ts})
    if not res.get("ok"):
        sys.exit(f"thread error: {res.get('error')}")
    return [{"ts": m["ts"], "text": m.get("text", ""), "user": m.get("user")}
            for m in res.get("messages", [])]

def history(channel, oldest=None):
    params = {"channel": channel, "limit": 50}
    if oldest:
        params["oldest"] = oldest
    res = _call("conversations.history", params)
    if not res.get("ok"):
        sys.exit(f"history error: {res.get('error')}")
    return [{"ts": m["ts"], "text": m.get("text", ""), "user": m.get("user")}
            for m in res.get("messages", [])]

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""

    if cmd == "search":
        print(json.dumps(search(sys.argv[2]), indent=2))

    elif cmd == "send":
        user_id = sys.argv[2]
        text = sys.stdin.read().strip()
        print(json.dumps(send(user_id, text), indent=2))

    elif cmd == "thread":
        print(json.dumps(thread(sys.argv[2], sys.argv[3]), indent=2))

    elif cmd == "history":
        oldest = sys.argv[3] if len(sys.argv) > 3 else None
        print(json.dumps(history(sys.argv[2], oldest), indent=2))

    else:
        print(__doc__)
        sys.exit(1)
