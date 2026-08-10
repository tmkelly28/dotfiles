# Multi-instance Claude Code status indicator for tmux (+ persistent macOS alerts & jump-to switcher)

A tmux status-bar indicator that summarises **every live Claude Code CLI instance at a glance** plus macOS
notifications that **stay on screen until dismissed** (and retract themselves once you look at the
instance they came from), and an fzf popup to jump straight to any instance's pane. Built and
verified on **macOS 15.6 + Ghostty + tmux 3.6a + stock bash 3.2 + Claude Code CLI**; the core is
portable, the notification module is macOS-specific and called out as such.

---

## Quick reference

**The status bar** (`status-right`), e.g. `●2  👁3  ✋games  ✅notes`:

| Element           | Meaning                                            |
| ----------------- | -------------------------------------------------- |
| `●N` (blue)       | N instances **actively processing right now**      |
| `👁M` (grey)      | M instances **idle / already seen**                |
| `✋name` (orange) | instance **blocked waiting for your approval**     |
| `✅name` (green)  | instance that **just finished**, not yet looked at |
| `· claude idle`   | nothing running                                    |

Counters lead so they survive truncation. `name` is the **tmux session name**. `✅` collapses into
`👁` once you focus that pane. More than 4 finished at once collapse to `✅+K`.

**Keys and commands**

| Action                           | How                                                       |
| -------------------------------- | --------------------------------------------------------- |
| Jump to any instance             | `prefix + a` → fzf popup (live pane preview) → `Enter`    |
| Dismiss one alert                | Look at that instance's pane — it retracts itself         |
| Dismiss all alerts for a session | Send it new work (`running` retracts), or end the session |
| Force a status-bar redraw        | `tmux refresh-client -S`                                  |
| Rebuild the notifier app         | `~/.claude/hooks/claude-notifier-install.sh`              |

**The day-to-day loop:** fire off work in several panes → tab away to a browser/editor → an alert
sits on screen per finished-or-blocked instance until you deal with it → open your terminal, look
at that pane, its alert disappears and its `✅` folds into `👁` → `prefix + a` to hop to the next.

**Where things live**

| Path                             | What                                        |
| -------------------------------- | ------------------------------------------- |
| `~/.claude/hooks/*.sh`           | all scripts                                 |
| `~/.claude/status/<session-id>`  | state file, `state\|epoch\|pane\|cwd`       |
| `~/.claude/status/.viewed-<id>`  | "you've looked at this" marker              |
| `~/.claude/status/.notify-<id>`  | "an alert is currently posted" marker       |
| `~/.claude/bin/ClaudeNotify.app` | private notifier bundle (Module 7)          |
| `~/.claude/settings.json`        | hook wiring                                 |
| `~/dotfiles/.tmux.conf`                   | status-right, focus hooks, switcher binding |

---

## What this is and why

People increasingly run **several Claude Code CLI sessions at once** — one per project, worktree,
or tmux pane. You lose track of them. Which are actively working? Which are blocked waiting for
you to approve a command? Which finished five minutes ago and are just sitting there? You end up
cycling through panes to check, and an agent that finished while you were in a browser can idle
for a long time before you notice.

This solves that with four things:

1. A **tmux status-bar indicator** summarising every live instance at a glance.
2. **macOS alerts** when an instance finishes or needs approval _while you're not looking at the
   terminal_ — deliberately **manual-dismiss**, so they're still there when you come back.
3. **Automatic retraction** of an alert once you've actually seen that instance, so persistence
   never turns into a pile of stale alerts to clear by hand.
4. A **popup switcher** to jump straight to any instance's pane.

The design point worth keeping: the status bar answers _"what's the state of everything?"_ at a
glance, and the alerts answer _"do I need to come back to the terminal at all?"_ when you're
elsewhere.

---

## For the implementing agent (read this first)

> **Default: build this as specified — then check in about variations.**
> The reader most likely saw this demonstrated and wants the same thing. Reproduce it as
> described. The defaults encode decisions arrived at by hitting the problems in _Known gotchas_ —
> treat them as load-bearing.
>
> **Do not open with "so which parts would you like?"** — that dumps design work on someone who
> just wants it working. Instead:
>
> 1. **State the plan and confirm it** — one question, phrased so "yes, all of it" is the easy
>    answer. For example, verbatim: _"I'll install the full setup: the tmux status indicator for
>    all your Claude instances, persistent macOS alerts that auto-dismiss once you view the
>    instance, and a `prefix + a` popup switcher. Eight modules, roughly 15 minutes, and I'll
>    verify each one as I go. Sound good?"_
> 2. **Interview only where their environment forces a decision** — not macOS (Module 6/7 are
>    macOS-only as written), not tmux, a different terminal app (`TERMINAL_APP` must match their
>    terminal's process name), `prefix + a` already bound, an existing `~/.claude/settings.json`
>    with a `hooks` key to merge into, no `jq`/`fzf`. These are _compatibility_ questions, not
>    preference questions. Don't silently substitute — ask, then adapt.
> 3. **Call out the genuinely optional pieces**, so opting out is cheap and informed: Module 5
>    (viewed-collapse), Module 6+7 (notifications), Module 8 (switcher). Modules 1–4 are the core
>    and only make sense together.
> 4. **Then invite variations** — and build them if asked. Don't propose a redesign unprompted.
>
> Deviate when the user asks or their environment requires it. Not because something looks
> tidier — that's how the gotchas get reintroduced.

The modules below are independently installable, so a user who wants only the status bar, or only
the notifications, can have exactly that — but that's their call to make, not your opening move.

---

## Known gotchas

**Load-bearing — don't simplify these away.** Each cost real debugging time.

| #   | Symptom                                                                            | Cause                                                                                                                                                                                            | Fix                                                                                                                                                                          | Module |
| --- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 1   | `●` never lights up                                                                | "Working" is detected by grepping the pane's footer for `esc to interrupt`, a Claude TUI string, not a public API                                                                                | Update `WORKING_MARK` at the top of `claude-tmux-status.sh` **and** `claude-switcher.sh`                                                                                     | 3, 8   |
| 2   | `✋`/`✅` never appear for a session                                               | Hook config only applies to **newly started** Claude sessions                                                                                                                                    | Restart the session. Discovery still lists old ones as `👁` — that's intended                                                                                                | 1      |
| 3   | Scripts fail with `declare -A` / substitution errors                               | macOS ships **bash 3.2**                                                                                                                                                                         | Scripts avoid associative arrays and modern syntax on purpose; keep that if you edit them                                                                                    | all    |
| 4   | Notifier call hangs the hook                                                       | `terminal-notifier`'s `-sender` / `-activate` flags can hang                                                                                                                                     | Use only `-title/-message/-group` (and `-remove`) as shown                                                                                                                   | 6, 7   |
| 5   | Everything looks correctly configured but **no notification ever pops**            | macOS suppresses **all** notifications — banners _and_ alerts — while the display is **mirrored or shared**, silently routing them to Notification Center. Costs hours if you record screencasts | System Settings → Notifications → **"Allow notifications when mirroring or sharing the display" = ON**. Diagnose with `system_profiler SPDisplaysDataType \| grep -i mirror` | 6, 7   |
| 6   | Editing Homebrew `terminal-notifier.app`'s `Info.plist` to `alert` changes nothing | macOS seeds an app's alert style from `NSUserNotificationAlertStyle` **only on that bundle id's first registration**. An already-registered app ignores it forever                               | Use a **copy with its own unused `CFBundleIdentifier`** (Module 7). This is the whole reason that module exists — not cosmetics                                              | 7      |
| 7   | `-remove` silently does nothing                                                    | `NSUserNotificationCenter` only manages **its own app's** delivered notifications                                                                                                                | The retract must run through the **same bundle that posted** — `ClaudeNotify.app`'s binary, not the Homebrew `terminal-notifier` on `PATH`                                   | 7      |
| 8   | Notifier process spawns constantly / hooks feel sluggish                           | `running` fires on **every tool call**; an ungated retract launches a GUI binary each time                                                                                                       | Gate every retract on `.notify-<id>` existing — it doubles as "an alert is currently posted"                                                                                 | 7      |
| 9   | Alerts pile up unread even after you've seen them                                  | Manual-dismiss is the point, but nothing was retracting them                                                                                                                                     | The retract hooks in Module 7 are not optional polish; without them persistence becomes a chore                                                                              | 7      |
| 10  | Alert style silently reverts to Banners                                            | Changing `BUNDLE_ID` later makes macOS treat it as a **brand-new app**, re-seeded and re-listed, with the old entry lingering in System Settings                                                 | Pick the id once and keep it. Re-running the installer with the same id is safe and preserves the style                                                                      | 7      |
| 11  | Duplicated tmux hooks after every config reload                                    | `set-hook -ga` **appends**                                                                                                                                                                       | Use `set-hook -g` (plain) as shown                                                                                                                                           | 5      |
| 12  | A Claude instance never appears                                                    | Discovery maps process TTY → tmux pane, so instances **outside tmux** are invisible, as are ones on another host or tmux server                                                                  | Expected limitation; run Claude inside tmux                                                                                                                                  | 2      |
| 13  | `prefix + a` does nothing / hits a plugin                                          | Key already bound (e.g. `t-smart-tmux-session-manager` binds `T`)                                                                                                                                | Check `tmux list-keys -T prefix \| grep " a "` and pick a free key                                                                                                           | 8      |
| 14  | Editing the `.app` "breaks its signature"                                          | Homebrew's build is **ad-hoc, linker-signed, `Info.plist=not bound`** — editing `Info.plist` is safe and needs no re-sign                                                                        | Confirm with `codesign -dv <app>`. If yours shows a real TeamIdentifier / sealed resources, re-sign after editing: `codesign --force --sign - <app>`                         | 7      |
| 15  | Status bar truncates                                                               | tmux `status-right-length` defaults to 40                                                                                                                                                        | Set it to ~120                                                                                                                                                               | 4      |

Two smaller ones: state markers are **dotfiles on purpose** (`.viewed-`/`.notify-`) so the
`"$dir"/*` glob that walks state files skips them; and this is **`~/.claude`-global**, monitoring
all your Claude sessions rather than one project.

---

## Dependencies at a glance

| Module                | Hard dependencies                                                                                              | Alternatives / notes                                                                                                |
| --------------------- | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| 1 — State tracking    | Claude Code CLI, `jq`, bash                                                                                    | None; this is the foundation                                                                                        |
| 2 — Process discovery | `ps`, `awk`, `sort`, `grep`, tmux                                                                              | `ps -Ao tty,command` works on macOS + Linux; adjust flags for an unusual `ps` (e.g. `-o tty,cmd`)                   |
| 3 — Renderer          | Modules 1–2, tmux, `awk`, `grep`                                                                               | —                                                                                                                   |
| 4 — tmux wiring       | tmux (any modern version)                                                                                      | —                                                                                                                   |
| 5 — Viewed collapse   | tmux with `focus-events on`, `set-hook` (tmux ≥ 3.0)                                                           | Skip it and finished instances stay `✅` until the session ends                                                     |
| 6 — Notifications     | macOS; `terminal-notifier` **or** `alerter` **or** built-in `osascript`; AppleScript **Automation** permission for the terminal | Linux: swap `notify()` for `notify-send` and `user_is_looking()` for your WM's focus query (or always return false) |
| 7 — Persistent alerts | Module 6, `terminal-notifier` (**not** the `osascript` fallback), `plutil`, `lsregister`                       | macOS-only. Module 5 too, for view-triggered dismissal — see the module's note                                      |
| 8 — Switcher          | tmux ≥ 3.2 (`display-popup`), `fzf`                                                                            | `tmux display-menu` (no fuzzy search, no preview)                                                                   |

Author's baseline for reference: macOS 15.6, Ghostty 1.2.3 (quick-terminal/quake mode), tmux 3.6a,
fish as the interactive shell (irrelevant — every script is bash), Homebrew at `/opt/homebrew`.
Substitute freely; the only environment values that must match reality are `TERMINAL_APP` and any
absolute tool paths.

---

## The implementation

Create `~/.claude/hooks/` and `~/.claude/status/` if absent, and `chmod +x` every script.
Paths use `$HOME` throughout — every one of these runs through a shell (tmux `#(...)`,
`run-shell`, `display-popup -E`, Claude Code hook commands), so it expands. If a path fails to
resolve, substitute an absolute home directory and re-test.

### Module 1 — State tracking via Claude Code hooks (core)

On each Claude lifecycle event, write `~/.claude/status/<session-id>` = `state|epoch|pane|cwd`,
where state is `running` / `permission` / `done`; `clear` deletes it. Files: `claude-status.sh`
(below, shared with Modules 6–7) + the hooks block in `~/.claude/settings.json`.

### Module 2 — Process discovery (core)

Prints the tmux `pane_id` of every live `claude` process by matching process TTY to pane TTY.
**This is what makes idle instances appear at all** — a purely event-driven design misses them,
and shows a stuck "working" indicator after an ESC interrupt.

`~/.claude/hooks/claude-live-panes.sh`:

```bash
#!/usr/bin/env bash
# Outputs the tmux pane_id (one per line) of every live Claude Code CLI instance,
# by matching each `claude` process's TTY to a tmux pane's TTY. Authoritative and
# self-correcting: finds idle instances and ones with no state file.

# TTYs of live `claude` CLI processes. `$1 != "??"` drops the tty-less
# chrome-native-host helper; the basename check keeps only the real CLI.
ttys="$(ps -Ao tty,command 2>/dev/null | awk '
  $1 != "??" {
    n = split($2, p, "/")
    if (p[n] == "claude") print $1
  }
' | sort -u)"
[ -n "$ttys" ] || exit 0

# Emit the pane whose tty matches each claude tty (pane_tty is /dev/ttysNNN).
tmux list-panes -a -F '#{pane_tty} #{pane_id}' 2>/dev/null | while read -r ptty pid; do
  printf '%s\n' "$ttys" | grep -qxF "${ptty#/dev/}" && printf '%s\n' "$pid"
done
```

### Module 3 — Status-line renderer (core)

For each discovered pane: footer says working → `●`; otherwise overlay the newest state file for
that pane. Three signals, each used for what it's best at — **which instances exist** comes from
process discovery, **is it working right now** from the pane's own footer (never stuck, unlike an
event flag after an interrupt), **everything else** from hook state files.

`~/.claude/hooks/claude-tmux-status.sh`:

```bash
#!/usr/bin/env bash
# Prints the one-line Claude status summary for tmux status-right.
#   1. Which instances exist   -> claude-live-panes.sh (TTY -> pane).
#   2. Is it working right now -> the pane footer shows "esc to interrupt".
#   3. Other states            -> hook state files ~/.claude/status/<sid>.
# Layout: ●N 👁M ✋<perm names> ✅<done names, cap then ✅+K>   (counters lead).
# Written for macOS's stock bash 3.2.

dir="$HOME/.claude/status"
panes_helper="$HOME/.claude/hooks/claude-live-panes.sh"
DONE_CAP=4
WORKING_MARK='esc to interrupt'   # Claude's footer shows this only while processing

live_panes=" $(tmux list-panes -a -F '#{pane_id}' 2>/dev/null | tr '\n' ' ') "

# Load state files into arrays; prune files whose pane is truly gone.
n=0
shopt -s nullglob
for f in "$dir"/*; do
  IFS='|' read -r st ts pn cw < "$f"
  sid="$(basename "$f")"
  if [ -n "$pn" ]; then
    case "$live_panes" in
      *" $pn "*) : ;;
      *) rm -f "$f" "$dir/.viewed-$sid" "$dir/.notify-$sid"; continue ;;
    esac
  fi
  A_STATE[$n]="$st"; A_TS[$n]="${ts:-0}"; A_PANE[$n]="$pn"; A_SID[$n]="$sid"
  n=$((n + 1))
done

running=0; viewed=0; done_count=0; perm_l=""; done_l=""

pane_working() {  # 0 (true) if the pane's footer shows Claude is processing
  tmux capture-pane -p -t "$1" 2>/dev/null | awk 'NF{l=$0} END{print l}' | grep -q "$WORKING_MARK"
}

classify_idle() {  # state sid label -- for a pane that is NOT actively working
  local state="$1" sid="$2" label="$3"
  case "$state" in
    permission) perm_l="$perm_l #[fg=colour208,bold]✋${label}#[default]" ;;
    done)
      if [ -n "$sid" ] && [ -f "$dir/.viewed-$sid" ]; then
        viewed=$((viewed + 1))
      else
        done_count=$((done_count + 1))
        [ "$done_count" -le "$DONE_CAP" ] && done_l="$done_l #[fg=colour46,bold]✅${label}#[default]"
      fi ;;
    *)          viewed=$((viewed + 1)) ;;   # idle / stuck-running / waiting / untracked
  esac
}

for pane in $(bash "$panes_helper" 2>/dev/null); do
  label="$(tmux display-message -p -t "$pane" '#{session_name}' 2>/dev/null)"
  [ -n "$label" ] || label="claude"

  if pane_working "$pane"; then
    running=$((running + 1)); continue
  fi

  bi=-1; bts=-1; k=0
  while [ "$k" -lt "$n" ]; do
    if [ "${A_PANE[$k]}" = "$pane" ] && [ "${A_TS[$k]}" -gt "$bts" ]; then bts="${A_TS[$k]}"; bi="$k"; fi
    k=$((k + 1))
  done
  if [ "$bi" -ge 0 ]; then classify_idle "${A_STATE[$bi]}" "${A_SID[$bi]}" "$label"
  else classify_idle "idle" "" "$label"; fi
done

if [ "$done_count" -gt "$DONE_CAP" ]; then
  done_l="$done_l #[fg=colour46,bold]✅+$((done_count - DONE_CAP))#[default]"
fi

out=""
[ "$running" -gt 0 ] && out="$out #[fg=colour39]●${running}#[default]"
[ "$viewed" -gt 0 ]  && out="$out #[fg=colour244]👁${viewed}#[default]"
out="$out$perm_l$done_l"

if [ -n "$out" ]; then printf '%s' "${out# }"
else printf '#[fg=colour240]· claude idle#[default]'; fi
```

### Module 4 — tmux wiring (core)

See the `~/dotfiles/.tmux.conf` block at the end of this section; Module 4 is the first two lines.

### Module 5 — "Viewed" collapse (optional)

When you **focus** a finished instance's pane, drop a `.viewed-<id>` marker so `✅name` collapses
into the `👁` count — gated on real focus, so an instance finishing while your terminal is
backgrounded stays a visible `✅`. The same hook retracts that instance's alert (Module 7).

Skipping this: also drop the five `set-hook` lines from `~/dotfiles/.tmux.conf`, and Module 7 loses
view-triggered dismissal (it still retracts on `running`/`clear`).

`~/.claude/hooks/claude-mark-viewed.sh`:

```bash
#!/usr/bin/env bash
# Marks finished ('done') Claude sessions as "viewed" once you actually focus
# their pane, so they collapse from the named list into the 👁 counter.
#
# Invoked (backgrounded) by tmux focus/navigation hooks in ~/dotfiles/.tmux.conf:
#   after-select-pane, after-select-window, client-session-changed,
#   client-attached, client-focus-in.
# Using client-focus-in means "viewed" only counts when the terminal itself
# has OS focus -- a task finishing while the terminal is backgrounded is NOT hidden.

dir="$HOME/.claude/status"
[ -d "$dir" ] || exit 0

# Focused pane(s): the active pane of the active window of each attached session.
focused=" $(tmux list-panes -a \
  -f '#{&&:#{pane_active},#{&&:#{window_active},#{session_attached}}}' \
  -F '#{pane_id}' 2>/dev/null | tr '\n' ' ') "

changed=0
shopt -s nullglob
for f in "$dir"/*; do
  IFS='|' read -r state ts pane cwd < "$f"
  [ -n "$pane" ] || continue
  case "$focused" in *" $pane "*) ;; *) continue ;; esac
  sid="$(basename "$f")"

  [ "$state" = "done" ] && { marker="$dir/.viewed-$sid"; [ -f "$marker" ] || { touch "$marker"; changed=1; }; }

  # --- Module 7: looking at the pane means you've seen it, so retract its macOS alert.
  # Those are manual-dismiss and would otherwise pile up until clicked. .notify-<sid>
  # doubles as "an alert is currently posted", so this fires once and only when there's
  # one to pull down. Applies to `permission` too: the ✋ in the bar is the standing
  # reminder. Delete this block if you skip Module 7.
  if [ -f "$dir/.notify-$sid" ]; then
    "$HOME/.claude/hooks/claude-notify-clear.sh" "$sid"
    rm -f "$dir/.notify-$sid"
  fi
done

# Only force a redraw when something actually changed.
[ "$changed" -eq 1 ] && tmux refresh-client -S 2>/dev/null
exit 0
```

### Module 6 — Desktop notifications (optional, macOS as written)

Notify on `permission`/`done` **only when the terminal isn't frontmost** (so you're never spammed
while watching), de-duplicated per session, silent. Lives inside `claude-status.sh` below.

### Module 7 — Persistent alerts that retract themselves (optional, macOS)

**The problem it solves:** a banner auto-fades after a few seconds. If you're away from the desk
when an agent finishes, you miss it entirely and the whole notification is wasted. macOS's
**Alerts** style stays on screen until dismissed — but alert style is a **per-app OS setting**,
not something a notification payload can request.

**Why a private app bundle:** macOS seeds an app's style from `NSUserNotificationAlertStyle` in
its `Info.plist`, but **only the first time that bundle id registers**. Homebrew's
`terminal-notifier` is long since registered as `banner`, so editing its plist does nothing — and
flipping its style by hand in System Settings would make _every_ script that uses it persistent.
So: a copy of the bundle with its own `CFBundleIdentifier`. It also makes notifications read as
**"Claude Code"** rather than "terminal-notifier".

**Why it auto-retracts:** persistence without retraction just moves the chore. Every alert is
tagged `-group claude-<session-id>`, which is a precise handle to pull that one back down, from
three places: you focused that instance's pane (Module 5), work resumed, or the session ended.
Only the _focused_ instance's alert is retracted — the others keep standing, which is the point.

`~/.claude/hooks/claude-notifier-install.sh` — run once (and again after
`brew upgrade terminal-notifier`):

```bash
#!/usr/bin/env bash
# (Re)builds ~/.claude/bin/ClaudeNotify.app -- a private copy of terminal-notifier.app used
# by claude-status.sh to post macOS notifications that DO NOT auto-dismiss.
#
# Why a copy: macOS alert style is per-app, and an app's *initial* style is seeded from
# NSUserNotificationAlertStyle in its Info.plist the first time it registers. Homebrew's
# terminal-notifier ships "banner" and is already registered, so the only way to get
# persistent Alerts without hijacking every other terminal-notifier caller is a bundle with
# its own CFBundleIdentifier. Bonus: notifications are attributed to "Claude Code".
#
# Run again after `brew upgrade terminal-notifier` to pick up the new binary. The bundle id
# stays the same, so the alert style already chosen in System Settings is preserved.
set -euo pipefail

# Any reverse-DNS id you have NEVER used before -- the unused-ness is what makes the style
# seeding work. Put your own name/domain in it. Don't change it later (see gotcha 10).
BUNDLE_ID="com.example.claude-notify"
BUNDLE_NAME="Claude Code"
DST="$HOME/.claude/bin/ClaudeNotify.app"

src_bin="$(command -v terminal-notifier || true)"
[ -n "$src_bin" ] || { echo "terminal-notifier not found -- brew install terminal-notifier" >&2; exit 1; }

# Locate terminal-notifier.app. Homebrew's bin/terminal-notifier is a two-line wrapper that
# execs the binary inside the bundle, so read the path straight out of it; other install
# layouts put the CLI inside the bundle itself, so fall back to resolving the symlink.
SRC="$(sed -n 's|.*"\(/.*\.app\)/Contents/MacOS/[^"]*".*|\1|p' "$src_bin" 2>/dev/null | head -1)"
if [ ! -d "${SRC:-}" ]; then
  real="$(readlink -f "$src_bin" 2>/dev/null || python3 -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "$src_bin")"
  case "$real" in */Contents/MacOS/*) SRC="${real%/Contents/MacOS/*}" ;; esac
fi
[ -d "${SRC:-}" ] || { echo "could not locate terminal-notifier.app (from $src_bin)" >&2; exit 1; }

mkdir -p "$(dirname "$DST")"
rm -rf "$DST"
cp -R "$SRC" "$DST"

plist="$DST/Contents/Info.plist"
plutil -replace CFBundleIdentifier            -string "$BUNDLE_ID"   "$plist"
plutil -replace CFBundleName                  -string "$BUNDLE_NAME" "$plist"
plutil -replace NSUserNotificationAlertStyle  -string "alert"        "$plist"

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$DST"

echo "built $DST ($BUNDLE_ID)"
echo "verify: System Settings > Notifications > \"$BUNDLE_NAME\" -> Alert style = Alerts"
"$DST/Contents/MacOS/terminal-notifier" -title "Claude Code" -message "Persistent alert test -- this should stay until dismissed" -group claude-install-test
```

`~/.claude/hooks/claude-notify-clear.sh`:

```bash
#!/usr/bin/env bash
# Pulls down the macOS alert(s) that claude-status.sh posted for the given session id(s).
# Usage: claude-notify-clear.sh <session-id> [session-id...]
#
# The alerts are manual-dismiss by design (see claude-notifier-install.sh), so something has
# to retract them once they're moot. Callers:
#   * claude-mark-viewed.sh -- you focused that instance's pane, so you've seen it
#   * claude-status.sh      -- the session went `running` again, or ended (`clear`)
#
# NSUserNotificationCenter only manages its own app's delivered notifications, so the remove
# MUST go through the same bundle that posted -- hence the ClaudeNotify.app path first, with
# the same fallback order as claude-status.sh's notify().
set -u

bin="$HOME/.claude/bin/ClaudeNotify.app/Contents/MacOS/terminal-notifier"
[ -x "$bin" ] || bin="$(command -v terminal-notifier 2>/dev/null || true)"
[ -n "$bin" ] || exit 0

for sid in "$@"; do
  [ -n "$sid" ] || continue
  "$bin" -remove "claude-$sid" >/dev/null 2>&1 || true
done
exit 0
```

**One manual step, once:** after the installer's test notification appears, open
**System Settings → Notifications → "Claude Code"** and confirm **Alert style = Alerts**. The
`Info.plist` seeding normally sets it; the dropdown is the ground truth, and one click fixes it
permanently if it reads Banners.

### Modules 1 + 6 + 7 — `~/.claude/hooks/claude-status.sh`

The shared entry point. Module boundaries are marked; delete a marked block to skip that module.

```bash
#!/usr/bin/env bash
# Records this Claude session's status for the tmux indicator, and fires a
# macOS notification when the session goes idle while the terminal is not the
# frontmost app (closed or tabbed away from).
# Usage: claude-status.sh <running|permission|done|clear>
# Hook JSON (with .session_id and .cwd) is read from stdin.

state="${1:-}"
dir="$HOME/.claude/status"
mkdir -p "$dir"

input="$(cat)"
sid="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)"
[ -n "$sid" ] || sid="unknown"
file="$dir/$sid"
notif_marker="$dir/.notify-$sid"
viewed_marker="$dir/.viewed-$sid"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"

# --- Module 7: an alert from the last idle may still be on screen (they're manual-dismiss).
# Work resuming or the session ending makes it moot, so retract it. Gated on the marker
# existing, since `running` fires on every tool call and must not spawn the notifier each
# time. Delete this block if you skip Module 7.
case "$state" in
  running|clear)
    [ -f "$notif_marker" ] && "$HOME/.claude/hooks/claude-notify-clear.sh" "$sid"
    ;;
esac

# --- write / clear state for the tmux status bar (Module 1) ---
if [ "$state" = "clear" ]; then
  rm -f "$file" "$notif_marker" "$viewed_marker"
else
  # state | epoch | tmux pane (empty when not in tmux) | cwd -- written atomically
  # so the renderer / mark-viewed hook never see a half-written line.
  printf '%s|%s|%s|%s\n' "$state" "$(date +%s)" "${TMUX_PANE:-}" "$cwd" > "$file.tmp" \
    && mv -f "$file.tmp" "$file"
fi

# New work resumes: reset the notify marker (so the next idle notifies again) and
# drop the viewed marker (a fresh cycle should re-show, not stay collapsed).
[ "$state" = "running" ] && rm -f "$notif_marker" "$viewed_marker"

# ============ Module 6 (+7): notify when idle and you're not looking ============
TERMINAL_APP="ghostty"   # System Events process name of YOUR terminal (case-insensitive)

# Module 7's private bundle: same terminal-notifier binary, but its own CFBundleIdentifier
# and NSUserNotificationAlertStyle=alert, so what it posts stays on screen until dismissed.
# Falls back to plain terminal-notifier (banners) if Module 7 isn't installed.
NOTIFIER_BIN="$HOME/.claude/bin/ClaudeNotify.app/Contents/MacOS/terminal-notifier"

notify() {
  local title="$1" msg="$2" bin="$NOTIFIER_BIN"
  [ -x "$bin" ] || bin="$(command -v terminal-notifier 2>/dev/null || true)"
  if [ -n "$bin" ]; then
    # Plain, non-blocking, silent. -sender/-activate can hang; don't add them.
    # For it to actually POP (not just land in Notification Center):
    #   1. alert style is Banners or Alerts, not None (System Settings > Notifications)
    #   2. "Allow notifications when mirroring or sharing the display" = ON
    #      -- macOS hides ALL notifications while the screen is mirrored/recorded otherwise.
    # -group is also the handle claude-notify-clear.sh uses to pull the alert back down.
    "$bin" -title "$title" -message "$msg" -group "claude-$sid" >/dev/null 2>&1 || true
  else
    local t="${title//\\/\\\\}"; t="${t//\"/\\\"}"
    local m="${msg//\\/\\\\}";   m="${m//\"/\\\"}"
    osascript -e "display notification \"$m\" with title \"$t\"" 2>/dev/null || true
  fi
}

# Returns 0 when you ARE looking at the terminal (it's frontmost) -> suppress notify.
user_is_looking() {
  local front
  front="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)"
  if [ -n "$front" ]; then
    [ "$(printf '%s' "$front" | tr '[:upper:]' '[:lower:]')" = "$(printf '%s' "$TERMINAL_APP" | tr '[:upper:]' '[:lower:]')" ]
    return
  fi
  # Frontmost unknown (e.g. Automation permission denied) -> fall back to tmux clients.
  if [ -n "$TMUX" ]; then
    local clients; clients="$(tmux list-clients 2>/dev/null | wc -l | tr -d ' ')"
    [ "${clients:-0}" -gt 0 ]; return
  fi
  return 1
}

case "$state" in
  done|permission)
    # Notify only when you're NOT looking at the terminal, and dedupe on state change.
    last="$(cat "$notif_marker" 2>/dev/null || true)"
    if ! user_is_looking && [ "$state" != "$last" ]; then
      proj="$(basename "$cwd" 2>/dev/null)"
      [ -n "$proj" ] && [ "$proj" != "." ] || proj="claude"
      if [ "$state" = "permission" ]; then
        notify "Claude · needs approval" "✋ $proj needs your approval"
      else
        notify "Claude · done" "✅ $proj finished — your turn"
      fi
      printf '%s' "$state" > "$notif_marker"
    fi
    ;;
esac
# ====================== end Modules 6/7 ======================

# Redraw the tmux status bar immediately (server-wide, best-effort).
tmux refresh-client -S 2>/dev/null || true
exit 0
```

### Module 8 — Jump-to switcher popup (optional)

`prefix + a` → fzf popup of every instance (state emoji, `session:window.pane`, project, age)
with a live preview of that pane; `Enter` jumps to it.

`~/.claude/hooks/claude-switcher.sh`:

```bash
#!/usr/bin/env bash
# fzf popup listing every live Claude instance; Enter jumps to its pane.
# Bound to `prefix + a` via display-popup.

dir="$HOME/.claude/status"
panes_helper="$HOME/.claude/hooks/claude-live-panes.sh"
WORKING_MARK='esc to interrupt'

FZF=fzf
command -v fzf >/dev/null 2>&1 || FZF=/opt/homebrew/bin/fzf   # fallback path; adjust if needed

now="$(date +%s)"

n=0
shopt -s nullglob
for f in "$dir"/*; do
  IFS='|' read -r st ts pn cw < "$f"
  A_STATE[$n]="$st"; A_TS[$n]="${ts:-0}"; A_PANE[$n]="$pn"; A_CWD[$n]="$cw"; A_SID[$n]="$(basename "$f")"
  n=$((n + 1))
done

pane_working() { tmux capture-pane -p -t "$1" 2>/dev/null | awk 'NF{l=$0} END{print l}' | grep -q "$WORKING_MARK"; }

rows=""
for pane in $(bash "$panes_helper" 2>/dev/null); do
  bi=-1; bts=-1; k=0
  while [ "$k" -lt "$n" ]; do
    if [ "${A_PANE[$k]}" = "$pane" ] && [ "${A_TS[$k]}" -gt "$bts" ]; then bts="${A_TS[$k]}"; bi="$k"; fi
    k=$((k + 1))
  done
  if [ "$bi" -ge 0 ]; then st="${A_STATE[$bi]}"; ts="${A_TS[$bi]}"; cwd="${A_CWD[$bi]}"; sid="${A_SID[$bi]}"
  else st="idle"; ts=0; cwd=""; sid=""; fi

  if pane_working "$pane"; then
    emoji="●"; status="working"
  else
    case "$st" in
      permission) emoji="✋"; status="needs approval" ;;
      done)       if [ -n "$sid" ] && [ -f "$dir/.viewed-$sid" ]; then emoji="👁"; status="idle"; else emoji="✅"; status="done"; fi ;;
      *)          emoji="👁"; status="idle" ;;
    esac
  fi

  loc="$(tmux display-message -p -t "$pane" '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)"
  [ -n "$loc" ] || loc="$pane"
  if [ -n "$cwd" ]; then proj="$(basename "$cwd")"
  else proj="$(basename "$(tmux display-message -p -t "$pane" '#{pane_current_path}' 2>/dev/null)")"; fi
  [ -n "$proj" ] && [ "$proj" != "." ] || proj="—"

  if [ "$status" != "working" ] && [ "$ts" -gt 0 ]; then
    age=$(( now - ts ))
    if   [ "$age" -lt 60 ];   then when="${age}s ago"
    elif [ "$age" -lt 3600 ]; then when="$((age / 60))m ago"
    else                           when="$((age / 3600))h ago"; fi
  else when="$status"; fi

  rows="$rows${pane}"$'\t'"$emoji  $loc  $proj  $when"$'\n'
done

if [ -z "$rows" ]; then printf 'No Claude instances.\n'; sleep 1; exit 0; fi

sel="$(printf '%s' "$rows" | "$FZF" \
  --ansi --delimiter='\t' --with-nth=2.. --prompt='claude ▸ ' \
  --preview 'tmux capture-pane -pe -J -t {1}' --preview-window=right:60%)"

[ -n "$sel" ] || exit 0
pane="$(printf '%s' "$sel" | cut -f1)"
[ -n "$pane" ] || exit 0
sess="$(tmux display-message -p -t "$pane" '#{session_name}' 2>/dev/null)"
tmux switch-client -t "$sess" \; select-window -t "$pane" \; select-pane -t "$pane"
```

### `~/.claude/settings.json` — hooks block (merge into any existing file)

```json
{
	"hooks": {
		"UserPromptSubmit": [
			{
				"hooks": [
					{
						"type": "command",
						"command": "$HOME/.claude/hooks/claude-status.sh running"
					}
				]
			}
		],
		"PreToolUse": [
			{
				"hooks": [
					{
						"type": "command",
						"command": "$HOME/.claude/hooks/claude-status.sh running"
					}
				]
			}
		],
		"PostToolUse": [
			{
				"hooks": [
					{
						"type": "command",
						"command": "$HOME/.claude/hooks/claude-status.sh running"
					}
				]
			}
		],
		"Notification": [
			{
				"matcher": "permission_prompt",
				"hooks": [
					{
						"type": "command",
						"command": "$HOME/.claude/hooks/claude-status.sh permission"
					}
				]
			},
			{
				"matcher": "idle_prompt",
				"hooks": [
					{
						"type": "command",
						"command": "$HOME/.claude/hooks/claude-status.sh done"
					}
				]
			}
		],
		"Stop": [
			{
				"hooks": [
					{
						"type": "command",
						"command": "$HOME/.claude/hooks/claude-status.sh done"
					}
				]
			}
		],
		"SessionEnd": [
			{
				"hooks": [
					{
						"type": "command",
						"command": "$HOME/.claude/hooks/claude-status.sh clear"
					}
				]
			}
		]
	}
}
```

- **`PostToolUse → running` matters:** `PreToolUse` fires _before_ a permission prompt, so
  `PostToolUse` is what clears the `permission` state after you approve.
- **The `Notification` matcher split** is the reliable way to distinguish a permission prompt from
  an idle "your turn" — do **not** regex the notification message text. `matcher` goes on the
  group object, exactly as shown.

### `~/dotfiles/.tmux.conf` — additions

```tmux
# --- Claude status indicator (Module 4) ---
set -g status-right "#($HOME/.claude/hooks/claude-tmux-status.sh)"
set -g status-right-length 120          # default 40 truncates once several sessions are open

# Module 5: collapse a finished instance into 👁 once you focus its pane (and retract its
# alert, Module 7). focus-events must be on for client-focus-in to fire.
set -g focus-events on
set-hook -g after-select-pane      'run-shell -b "$HOME/.claude/hooks/claude-mark-viewed.sh"'
set-hook -g after-select-window    'run-shell -b "$HOME/.claude/hooks/claude-mark-viewed.sh"'
set-hook -g client-session-changed 'run-shell -b "$HOME/.claude/hooks/claude-mark-viewed.sh"'
set-hook -g client-attached        'run-shell -b "$HOME/.claude/hooks/claude-mark-viewed.sh"'
set-hook -g client-focus-in        'run-shell -b "$HOME/.claude/hooks/claude-mark-viewed.sh"'

# Module 8: popup switcher (pick a key that's free for you; verify prefix+a is unbound).
bind-key a display-popup -E -w 80% -h 60% "$HOME/.claude/hooks/claude-switcher.sh"
```

Reload with `tmux source-file ~/dotfiles/.tmux.conf`. Use plain `set-hook -g` (not `-ga`) so reloading
doesn't stack duplicate hooks; these hook names are unset by default and unused by common plugins.

---

## Install order

**Install all of it unless the user said otherwise.** Foundation first, so there's something
visible to demo at every step.

1. `mkdir -p ~/.claude/hooks ~/.claude/status` — and `chmod +x ~/.claude/hooks/*.sh` as you go.
2. **Modules 1–4 (core).** `claude-status.sh` (you can paste the full version now; Modules 6/7's
   blocks are inert until their scripts exist), `claude-live-panes.sh`,
   `claude-tmux-status.sh`, the settings.json hooks, the first two `~/dotfiles/.tmux.conf` lines.
   Reload tmux, **start a fresh Claude session** (gotcha 2) — the bar should light up. _Demoable._
3. **Module 5** — `claude-mark-viewed.sh` + the five `set-hook` lines. _Demoable: `✅` → `👁`._
4. **Module 6** — set `TERMINAL_APP`; grant the terminal **Automation** permission for System
   Events on first prompt; on macOS enable _Allow notifications when mirroring or sharing the
   display_ (gotcha 5). _Demoable: tab away, wait for a task to finish._
5. **Module 7** — `brew install terminal-notifier`, add `claude-notify-clear.sh`, set `BUNDLE_ID`
   in `claude-notifier-install.sh`, run it, then confirm the alert style in System Settings.
   _Demoable: an alert that outlives a banner and vanishes when you look at its pane._
6. **Module 8** — `claude-switcher.sh` + the `bind-key`; confirm the key is free first.

---

## Verification quick-checks

| Run this                                                                                        | Expect                                                                                                  |
| ----------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `bash ~/.claude/hooks/claude-live-panes.sh`                                                     | one pane id per live Claude instance. Cross-check: `tmux list-panes -a -F '#{pane_id} #{session_name}'` |
| `~/.claude/hooks/claude-tmux-status.sh \| sed -E 's/#\[[^]]*\]//g'`                             | the rendered line, colours stripped, e.g. `●1 👁2`                                                      |
| Start a task in a Claude pane                                                                   | `●` appears for it; on finish it becomes `✅<session>`                                                  |
| Trigger a tool needing approval (in a **fresh** session)                                        | `✋<session>`; approve → `●` → `✅`                                                                     |
| Focus a `✅` instance's pane                                                                    | it folds into the `👁` count                                                                            |
| `prefix + a`                                                                                    | popup lists every instance with a live preview; `Enter` jumps there                                     |
| Tab away from the terminal, let a task finish                                                   | one notification, titled **Claude Code**                                                                |
| `~/.claude/bin/ClaudeNotify.app/Contents/MacOS/terminal-notifier -list ALL`                     | a row per still-posted alert, with group `claude-<session-id>`                                          |
| Leave an alert for 30s without touching it                                                      | still on screen — that's Alerts style working (a banner would be long gone)                             |
| Now focus that instance's pane                                                                  | alert disappears on its own; `-list ALL` no longer shows it                                             |
| `defaults read ~/.claude/bin/ClaudeNotify.app/Contents/Info.plist NSUserNotificationAlertStyle` | `alert`                                                                                                 |

**How the known failure modes present:**

- **No notification at all, everything else fine** → mirroring (gotcha 5) first, then Focus mode,
  then alert style set to _None_ in System Settings.
- **Notification appears but fades in ~5s** → the bundle's style is Banners, not Alerts: check the
  System Settings dropdown for "Claude Code" (gotcha 6). Confirm you're posting through
  `ClaudeNotify.app`, not the Homebrew `terminal-notifier` on `PATH`.
- **Alerts appear but never retract** → `-remove` going through the wrong bundle (gotcha 7), or a
  stale/missing `.notify-<id>` marker (`ls -a ~/.claude/status/`).
- **`●` never appears, other states fine** → the footer string changed (gotcha 1).
- **`✋`/`✅` never appear for one session** → it predates the hook config (gotcha 2).

---

## Optional extensions

- **Emojis/colours:** the glyphs and `#[fg=colourNNN]` codes in `claude-tmux-status.sh` /
  `claude-switcher.sh` (tmux 256-colour palette). `DONE_CAP` controls how many `✅` names show
  before collapsing to `✅+K`.
- **Name idle instances too:** move that case out of the `*)` count in `classify_idle`.
- **Click-to-jump alerts:** `terminal-notifier -execute '<command>'` runs a shell command when the
  alert is clicked, so a click could switch tmux to the pane that raised it. Worth knowing if you
  use a quake/dropdown terminal: `open -a <Terminal>` only activates the app and can't summon a
  dropdown window — Ghostty 1.2.3 exposes a `QuickTerminalIntent` App Intent ("Open the Quick
  Terminal… if already open, do nothing") reachable from a one-action Shortcut via
  `shortcuts run "<name>"`; there is no CLI equivalent (`ghostty +new-window` is GTK/D-Bus,
  Linux-only). Deliberately **not** installed here — auto-retract on view proved cleaner than
  making the alert something you must click.
- **No tmux?** Modules 1, 6 and 7 work standalone; build a different front-end (menu-bar app,
  notification-only setup) on top of the `~/.claude/status/` files.

