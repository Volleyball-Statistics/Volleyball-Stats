# Volleyball Stats

A single-file volleyball stat tracker that works fully offline. No analytics. By default your
stats never leave the device they were entered on; optionally, a small coaching staff can sign
in to [shared data](#shared-data-optional) and record into one live copy together.

**On the Mac:** double-click `index.html`.

**On the iPhone:** <https://wghackl.github.io/Volleyball-Stats/> → Share → Add to Home Screen.

## Installing on the iPhone

1. Open <https://wghackl.github.io/Volleyball-Stats/> in **Safari** (must be Safari — Chrome
   on iOS can't install home-screen apps).
2. Tap the **Share** button, scroll down, tap **Add to Home Screen**, then **Add**.
3. Launch it from the icon at least once while still on Wi-Fi. That first launch lets the
   service worker cache the app.
4. Put the phone in airplane mode and open it again to confirm it works offline.

After step 3 it never needs the network again. The page is loaded from cache, and there is
no server to talk to — the site hosts a program, not your data.

### What is and isn't on the internet

| | Where it lives |
|---|---|
| The app (HTML/JS/icons) | Public GitHub repo, served by GitHub Pages |
| **Your teams, rosters, matches and stats** | **Your phone's local storage** — and, only if you sign in to shared data, the team's Supabase project, readable only by the accounts on its list |

Without signing in, nothing you type is ever uploaded. The hosted copy is byte-identical
for everyone and contains no data.

### Updating the app

Push a change to `main` and Pages redeploys within a minute or two. **Bump `VERSION` in
`sw.js` whenever `index.html` changes** — otherwise installed phones keep serving the old
cached copy forever. On the next launch the new worker takes over and the page reloads
itself once.

## Where your data lives

In `localStorage` (key `vbstats.v1`) — **not** in this folder, and not in the repo. Which
means:

- Unless you sign in to shared data, the Mac copy and the phone copy are **separate stores
  with no sync**. Same app, two sets of stats. Move data between them with the JSON export.
- Opening `index.html` in a different browser or profile shows an empty app.
- Clearing site data — or deleting the home-screen icon on iOS — erases the stats.
- iOS Safari evicts `localStorage` for ordinary sites after 7 days of no visits.
  Home-screen apps get their own storage container and aren't subject to that, which is
  another reason to install it properly rather than just bookmarking the URL.

Use **Matches → Export all data (JSON)** to back up. On a phone this is the only thing
standing between you and losing a season.

## Shared data (optional)

Lets the owner and a fixed, small group (e.g. two assistants) record into one live copy.
Every device keeps its own full copy and keeps working with no signal; changes upload when
the connection is back, and other devices see each tap within about a second.

**Who can get in.** Two locks, both controlled by the owner:

1. **Sign-ups are off** in the Supabase project, so the only accounts that exist are the
   ones the owner creates (Authentication → Users → Add user → Create new user, with
   **Auto Confirm User** ticked). One account per person — never a shared login.
2. **The database only answers emails on `public.allowed_emails`**, even for a signed-in
   account. The publishable key in `index.html` is public by design and grants nothing on
   its own. Never put the secret / `service_role` key anywhere in the app.

**One-time setup** (owner): open `supabase/schema.sql`, replace the three placeholder emails
with the real ones (lower-case), and run it in the Supabase dashboard → SQL Editor. It is
safe to re-run.

**Adding or removing someone:** add/delete their row in `allowed_emails` (Table Editor) and
create/delete their user. Taking an email off the list blocks it on its very next request;
the next time that device connects, its copy is wiped and it's signed out.

**Forgotten password:** delete the user and create it again with a new one. Stats belong
to the team, not to the account, so nothing is lost.

**Using it.** Matches → **Shared data** → email + password → **Sign in**. A pill next to the
app name shows *Synced*, *Uploading…*, *Offline · N changes waiting* or *Can't reach server*.

- The first sign-in on a device that already has data asks whether to **add it to the
  shared data** or **use only the shared data**. Pick the second for test or practice data.
- **Undo** takes back *your* last tap, never one recorded on someone else's phone. To fix
  anyone's stat, tap it in **Recent**.
- Two people editing the *same* stat at the same moment: the last save wins. Separate
  taps never collide.
- Filters, which match you're recording into, and your remembered take-off spots stay on
  each device.
- While signed in, **Import adds** a file's teams and matches and never removes anything.
  **Delete match** and **Erase everything** affect everyone, and say so.
- **Sign out** clears this device's copy (everything stays in the shared data). If changes
  are still waiting to upload, it warns first.

**Free-plan notes.** A free Supabase project pauses after about a week with no activity
(say, the off-season). Nothing is lost; un-pause it from the dashboard.

## Getting started

1. **Teams** → add your team, add players. A jersey number *or* a name is enough — neither
   is individually required.
2. **Teams** → add an opponent and its roster. For a team that won't give you names, type
   the numbers straight into the # box (`4, 9, 15, 22`) and they're added as separate
   players in one go. Rosters are reused across matches, so you build each opponent once.
3. **Matches** → pick the two teams and a date → Create.
4. **Match** → pick a player, tap stats. `+` next to the set pills starts a new set.
5. **Box Score** → full table for both teams, filterable by set, exportable to CSV. The
   **Match** picker at the top shows any past match (or use **Box Score** next to a match on
   the Matches tab) without changing which match the Match tab records into.

## Phone layout

The same file reflows below 700px into a phone-first tally screen. To see it on your Mac,
just narrow the browser window (or use Safari → Develop → Enter Responsive Design Mode).

What changes:

- **Tabs move to a bottom bar**, in thumb reach.
- **Roster becomes a sticky horizontal strip** of big jersey numbers that stays visible
  while you tap, so you never scroll between "pick player" and "tap stat".
- **Nine thumb-sized stat buttons** in a 3×3 grid — the ones you tap live — each showing
  its running count for the set. The remaining eight (passing, ball-handling, serve in
  play, and the error counterparts) sit behind **More stats**, which remembers whether you
  left it open.
- A full-width **Undo last stat** button.
- **Box Score shows one team at a time**, with a switch at the top, instead of both teams'
  22-column tables stacked.
- Every control is at least 44px — the iOS minimum touch target — and no text is smaller
  than 11px.

Nothing is duplicated in the data model; it's one app with two layouts.

This layout is what you get on the installed home-screen app — see
[Installing on the iPhone](#installing-on-the-iphone) above.

## Attack placement (where the ball went)

Optional. Every attack still counts whether or not you locate it.

**Recording.** Tap Kill / Att Error / In Play (or press `K` / `E` / `A`) and a popup asks
where it landed:

1. **Hit** or **Tip** (defaults to Hit every time; `H` / `T` on the keyboard).
2. **Where the hitter took off** — Power, Middle, Right side or Back row, drawn on their
   side of the net (`P` / `M` / `R` / `B`). It's remembered per player, and pre-filled from
   position the first time (OH → Power, MB → Middle, OPP → Right side), so usually you skip
   straight to the landing spot. The power side is the hitter's left, so it appears on the
   right of the drawing, as you see it across the net.
3. **Middle set type (optional).** When the take-off is Middle, **30 / 51 / 60** buttons
   appear beside Hit / Tip (`3` / `5` / `6` on the keyboard). It isn't remembered between attacks, since a
   middle's set changes play to play. Leave it blank and the attack still counts. The list is
   `MIDDLE_PLAYS` in `index.html`.
4. **Dug by (optional, In Play only).** The other team's numbers appear; tap the defender
   who dug it and a Dig is logged for them too. It saves switching team tabs mid-rally, and
   you stay on the attacking team. Pick it *before* the landing spot.
5. **Tap where it landed** on the court. That records the attack and closes the popup.

The confirmation that follows has an **Undo** button for about four seconds. It removes
exactly that attack (and its dig), even if you've tapped something since.

**Skip location** still records the attack, just without a spot. **Cancel** (or `Esc`, or
tapping outside) records nothing. Only in-court landings can be tapped — skip for balls
that went out or into the net.

**Shot chart.** Each located attack is a line from take-off to landing. **Orange = hit,
blue = tip** (tips also end in a diamond, hits in a circle, so it reads without colour).
**Solid = kill, dashed = not a kill.** The Match tab shows a live chart for whichever team
you're recording; it's open by default on a desktop and closed on a phone, and your toggle
sticks. Attacks recorded before exact spots existed are drawn as landing marks only,
scattered inside their zone.

**Zones** are the positions of the team *being attacked*, drawn like a rotation sheet with
the net at the top:

```
        ——— NET ———
     4      3      2      front row
     5      6      1      back row
```

The zone is derived from the tapped spot: columns are 3 m wide and the front row is
everything inside the 3 m line.

**Reading it.** The Box Score gets an *attack placement* panel per team: pick a player (or
all), filter to hits or tips, and you get the shot chart (with an **All attacks / Kills
only** switch) beside the zone grid, where each zone shows attacks, kills and hitting % for
that selection. "Kills only" filters the shot chart, not the zone counts. Once any middle
attack has a middle set, a **Middle sets** table shows attacks, kills, errors and hitting %
for 30 / 51 / 60, with untyped middle attacks on their own row. **Tap a row** (or use the
**Middle set: All / 30 / 51 / 60** filter) to narrow the whole panel — shot chart, zone grid
and summary — to that middle set; tap it again to clear. It combines with the player and
Shot filters. The table itself always shows every middle set so you can compare them, with
the selected one highlighted. The app always says "middle set" in full, because "set" on
its own means Set 1 / Set 2 of the match. Cell shading is a single-hue ramp on attack volume — the count is printed in
every cell too, so it reads fine in greyscale. **Export CSV** gives long format, one row per
player × shot × zone, easy to pivot.

Attacks recorded without a zone are counted and called out explicitly under the court
rather than silently dropped — otherwise the chart would look complete when it wasn't.

## Fixing a mistake

- **Undo** (the button, or `Z`) removes the most recent stat.
- The confirmation after each tap has its own **Undo** for that tap.
- **Tap any row in Recent** to change its player or stat, or delete it (Delete asks for a
  second tap). Changing an attack to a non-attack stat drops its placement, since a dig has
  no landing spot.

## Keyboard shortcuts (Match tab)

| Key | Stat | | Key | Stat |
|---|---|---|---|---|
| `K` | Kill              | | `T` | Assist |
| `E` | Attack error      | | `Y` | Ball handling error |
| `A` | Kept in play (neither) | | `B` | Block solo |
| `S` | Ace               | | `N` | Block assist |
| `X` | Service error     | | `M` | Block error |
| `W` | Serve in play     | | `D` | Dig |
| `3` `2` `1` `0` | Pass rating / reception error | | `F` | Dig error |
| `Z` | Undo last stat    | | | |

Select a player first — shortcuts record against whoever is highlighted.

## One tap per swing

There is no separate "attempt" button, and you never need one. Attempts are derived:

```
Total Attempts = Kills + Attack Errors + Kept in Play
Hitting %      = (Kills − Attack Errors) / Total Attempts
```

A kill counts itself as an attempt. An error counts itself as an attempt. **`Kept in Play`
(`A`) is only for the third case** — a swing that terminated nothing, because it got dug or
blocked back up. Pressing it alongside a kill would inflate the denominator and understate
the player.

Serves work the same way: `Ace` and `Serve Error` are self-counting, `Serve in Play` is the
remainder.

The readout above the buttons shows the selected player's K / E / attempts / hit% for the
match, updating on every tap, so you can watch attempts climb without recording them.

Hitting % can be negative — more errors than kills — and is shown as `-.083`, red below
zero and green at or above it.
