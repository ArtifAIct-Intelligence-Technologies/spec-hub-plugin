#!/bin/sh
# PO-90: before each prompt, compare this person's Spec Hub version with the one seen last.
# Same number: print nothing (no tokens spent). Different: one line asking the AI to call what_changed.
# ~/.spec-hub/feed holds the token from the feed_token tool (line 1); ~/.spec-hub/seen holds the last version.
dir="${SPEC_HUB_HOME:-$HOME/.spec-hub}"
url="${SPEC_HUB_CHANGES_URL:-https://spec.artifaict.team/api/changes}"
# PO-114: at session start, compare the installed plugin with the one the site offers; older prints one line, same prints nothing
if [ "$1" = "start" ] && [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  mine=$(sed -n 's/.*"version": *"\([0-9][0-9.]*\)".*/\1/p' "$CLAUDE_PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -n 1)
  latest=$(curl -fsS -m 2 "${SPEC_HUB_KIT_URL:-https://spec.artifaict.team/kit-version.json}" 2>/dev/null | sed -n 's/.*"plugin": *"\([0-9][0-9.]*\)".*/\1/p')
  if [ -n "$mine" ] && [ -n "$latest" ] && [ "$mine" != "$latest" ] && [ "$(printf '%s\n%s\n' "$mine" "$latest" | sort -V | tail -n 1)" = "$latest" ]; then
    mp=$(printf '%s' "$CLAUDE_PLUGIN_ROOT" | sed -n 's#.*/plugins/cache/\([^/]*\)/.*#\1#p')
    case "$mp" in ""|*[!A-Za-z0-9._-]*) mp="spec-hub" ;; esac
    echo "Spec Hub: the installed spec-hub plugin is $mine and the latest is $latest. Tell the person, in their language, and ask whether you should update it for them now. If they say yes, run: claude plugin marketplace update $mp && claude plugin update spec-hub@$mp and then ask them to start a new session. If they say no, give them that command to run later. To stop doing this by hand: /plugin, Marketplaces tab, choose $mp, turn on auto-update. If they installed it from claude.ai (Customize > Plugins), it updates by itself."
  fi
fi
token=$(head -n 1 "$dir/feed" 2>/dev/null | tr -d '[:space:]')
if [ -z "$token" ]; then
  [ "$1" = "start" ] && echo "Spec Hub: change notices are not set up. If the person wants them, call feed_token and write the token as the first line of $dir/feed (chmod 600)."
  exit 0
fi
now=$(curl -fsS -m 3 -H "Authorization: Bearer $token" "$url" 2>/dev/null | sed -n 's/.*"version":\([0-9]*\).*/\1/p')
[ -n "$now" ] || exit 0
seen=$(cat "$dir/seen" 2>/dev/null | tr -cd '0-9')
if [ -z "$seen" ]; then echo "$now" > "$dir/seen"; exit 0; fi
if [ "$now" != "$seen" ]; then
  echo "$now" > "$dir/seen"
  echo "Spec Hub: something about the person's work changed. Call what_changed since=$seen and tell them briefly, in their language, before carrying on (for example a blocked card is ready now)."
fi
exit 0
