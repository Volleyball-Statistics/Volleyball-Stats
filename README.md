# Volleyball Stats

A single-file, fully local volleyball stat tracker. No backend, no accounts, no analytics.
Your stats never leave the device they were entered on.

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
| **Your teams, rosters, matches and stats** | **Only in your phone's local storage** |

Nothing you type is ever uploaded. The hosted copy is byte-identical for everyone and
contains no data.

### Updating the app

Push a change to `main` and Pages redeploys within a minute or two. **Bump `VERSION` in
`sw.js` whenever `index.html` changes** — otherwise installed phones keep serving the old
cached copy forever. On the next launch the new worker takes over and the page reloads
itself once.

## Where your data lives

In `localStorage` (key `vbstats.v1`) — **not** in this folder, and not in the repo. Which
means:

- The Mac copy and the phone copy are **separate stores with no sync**. Same app, two sets
  of stats. Move data between them with the JSON export.
- Opening `index.html` in a different browser or profile shows an empty app.
- Clearing site data — or deleting the home-screen icon on iOS — erases the stats.
- iOS Safari evicts `localStorage` for ordinary sites after 7 days of no visits.
  Home-screen apps get their own storage container and aren't subject to that, which is
  another reason to install it properly rather than just bookmarking the URL.

Use **Matches → Export all data (JSON)** to back up. On a phone this is the only thing
standing between you and losing a season.

## Getting started

1. **Teams** → add your team, add players. A jersey number *or* a name is enough — neither
   is individually required.
2. **Teams** → add an opponent and its roster. For a team that won't give you names, type
   the numbers straight into the # box (`4, 9, 15, 22`) and they're added as separate
   players in one go. Rosters are reused across matches, so you build each opponent once.
3. **Matches** → pick the two teams and a date → Create.
4. **Match** → pick a player, tap stats. `+` next to the set pills starts a new set.
5. **Box Score** → full table for both teams, filterable by set, exportable to CSV.

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
- Every control is at least 44px — the iOS minimum touch target.

Nothing is duplicated in the data model; it's one app with two layouts.

This layout is what you get on the installed home-screen app — see
[Installing on the iPhone](#installing-on-the-iphone) above.

## Attack placement (where the ball went)

Optional. Every attack still counts whether or not you locate it.

**Recording.** Tap Kill / Att Error / In Play (or press `K` / `E` / `A`) and a popup asks
where it landed:

1. **Hit** or **Tip** (defaults to Hit every time; `H` / `T` on the keyboard).
2. **Where the hitter took off** — Left, Middle, Right or Back row, drawn on their side of
   the net. It's remembered per player, and pre-filled from position the first time
   (OH → Left, MB → Middle, OPP → Right), so usually you skip straight to step 3.
   Left/right are the *hitter's*, so their left side appears on the right of the drawing,
   as you see it across the net.
3. **Middle set type (optional).** When the take-off is Middle, a **30 / 51 / 60** row
   appears (`3` / `5` / `6` on the keyboard). It isn't remembered between attacks, since a
   middle's set changes play to play. Leave it blank and the attack still counts. The list is
   `MIDDLE_PLAYS` in `index.html`.
4. **Tap where it landed** on the court. That records the attack and closes the popup.

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
attack has a set type, a **Middle attacks by set** table shows attacks, kills, errors and
hitting % per type, with untyped middle attacks on their own row. Cell shading is a single-hue ramp on attack volume — the count is printed in
every cell too, so it reads fine in greyscale. **Export CSV** gives long format, one row per
player × shot × zone, easy to pivot.

Attacks recorded without a zone are counted and called out explicitly under the court
rather than silently dropped — otherwise the chart would look complete when it wasn't.

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
