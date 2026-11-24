# Chrome Stride

Sprint speed that comes from the leg cyberware you have installed, with a slow build-up, a stamina cost and a short burst on a double tap, for Cyberpunk 2077. Single-player only.
Version 1.4.3 | Built for game version 2.31, installed on 2.5 | Status: 1.2.0 and 1.4.0 confirmed in game on 2.31; 1.4.3 in use in my game on 2.5 and working; no written test record

> This is an unofficial fan work and is not approved/endorsed by CD PROJEKT RED. No game files are included.

## The problem

In the base game every character sprints at about the same speed. Leg cyberware changes jumps and dashes, but a fully chromed character does not run noticeably faster than a fresh one, and sprinting costs nothing, so there is no reason to save it for when it matters.

## What I built

A redscript file (772 lines), a TweakXL file (848 lines) and the small Python script that generates the TweakXL file from two tables. It changes: the sprint speed bonus of Reinforced Tendons and Fortified Ankles per tier, the game's speed caps, how fast the sprint builds up, what the sprint costs in stamina, and what a double tap of the sprint key does.

- Reinforced Tendons and Fortified Ankles give a sprint-only speed bonus per tier, from +17 % at tier 2 to +70 % at tier 5++. Half of it is fixed, half grows with the attribute the implant is attuned to (Reflexes or Body, full at 20). Half of the bonus needs more than 25 % health.
- The sprint builds up: it starts at 50 % of top speed and reaches full speed over 15 seconds, with more of the gain early. A stop, a wall or running out of stamina loses the build-up; jumps and slides keep it.
- Sprinting costs stamina (3 % per second). At 0 stamina you are winded and sprint slower until stamina is back above 30 %.
- The normal sprint is capped at 50 km/h. A double tap of sprint fires a burst up to 94 km/h (26 m/s, about a cheetah's measured top speed) that drains stamina fast.
- Carrying a body: x0.54 on the sprint and a 36 km/h ceiling, no burst.

## How it works

- All speed changes in the script are one `Multiplier` modifier on the `MaxSpeed` stat. It is added only while the player is in the sprint state and removed on every exit, so walking, running and vehicles are not affected.
- The script wraps five methods of the game's sprint state (`SprintEvents.OnEnter`, `OnUpdate`, `CleanupTwoStepSprint`, `EvaluateTwoStepSprint`, `AddMaxSpeedModifier`), all with `@wrapMethod`. The source audit checked all five against the 2.5 game scripts: they match.
- The build-up follows the speed you really have: when a sprint starts, the script reads the current ground speed and resumes the build-up from there. It cannot run more than 1.5 s ahead of the real speed.
- The burst uses Running Man's double-tap sprint. Without Running Man the game's two-step sprint is switched off, so the double-tap parts do nothing. The script charges Running Man's double sprint per second instead of per frame, and the TweakXL file sets Running Man's per-frame cost to 0.
- Settings are read from Mod Settings every frame, so changes apply at once. Without Mod Settings the defaults apply.
- The TweakXL file adds the tier bonuses as gameplay packages on the implant records, raises the `MaxSpeed` cap to 26 m/s, and raises the engine's ground and air speed limits for the player from 15 and 18 m/s to 26 m/s.

```text
package/r6/
  scripts/ChromeStride/ChromeStride.reds        sprint state: build-up, stamina, burst, carry penalty, settings
  tweaks/zz_ChromeStride/ChromeStride.yaml      tier bonuses and speed caps (generated)
tools/build_yaml.py                             writes ChromeStride.yaml from the tier tables
```

The tweak folder name starts with `zz_` so it loads after Running Man's own tweak file.

## Requirements

| Requirement | Version | Link |
|---|---|---|
| Cyberpunk 2077 | built on 2.31 | |
| redscript | a build for your game version | [Nexus Mods, mod 1511](https://www.nexusmods.com/cyberpunk2077/mods/1511) |
| TweakXL | a build for your game version | [Nexus Mods, mod 4197](https://www.nexusmods.com/cyberpunk2077/mods/4197) |
| Mod Settings (optional) | a build for your game version | [Nexus Mods, mod 4885](https://www.nexusmods.com/cyberpunk2077/mods/4885) |
| Running Man (optional) | | [Nexus Mods, mod 26611](https://www.nexusmods.com/cyberpunk2077/mods/26611) |

Without Mod Settings the default values apply. Without Running Man there is no burst. Recommended, not required: [Walk By Default](https://www.nexusmods.com/cyberpunk2077/mods/14515) with its sprint speed set to 7.5 (the start speed this mod assumes for a new character). Requirements are not bundled.

## Install

1. Install the requirements above.
2. Copy the contents of `package/` into the game folder, so that `r6\scripts\ChromeStride\ChromeStride.reds` and `r6\tweaks\zz_ChromeStride\ChromeStride.yaml` exist.
3. Start the game. With Mod Settings installed, the page "Chrome Stride" appears in its menu.

## Uninstall / roll back

1. Close the game.
2. Delete `r6\scripts\ChromeStride` and `r6\tweaks\zz_ChromeStride`.
3. Saves keep working: the mod stores nothing in the save. Mod Settings keeps the mod's values in its own settings file; they are not used without the mod.
4. Requirements are left alone. To restore an unmodified game, verify the game files in your launcher.

## Configuration

Mod Settings > Chrome Stride:

| Category | Setting | Default | Range |
|---|---|---|---|
| Sprint speed | Sprint speed limit (km/h) | 50 | 36 to 94 (94 = off) |
| Sprint speed | Sprint speed with a body (x) | 0.54 | 0.2 to 1.0 |
| Sprint speed | Speed limit carrying a body (km/h) | 36 | 10 to 94 |
| Sprint speed | Jenkins' Tendons: steady bonus | on | |
| Sprint stamina | Sprint stamina cost (% per second) | 3 | 0 to 15 |
| Sprint stamina | Winded sprint speed (x) | 0.6 | 0.3 to 1.0 |
| Sprint stamina | Recover from winded at (% stamina) | 30 | 5 to 100 |
| Burst (double tap sprint) | Burst on double tap | on | |
| Burst (double tap sprint) | Burst length (s) | 0 (as long as stamina lasts) | 0 to 10 |
| Burst (double tap sprint) | Burst power (x speed) | 1.35 | 1.0 to 2.0 |
| Burst (double tap sprint) | Burst top speed (km/h) | 94 | 40 to 94 |
| Burst (double tap sprint) | Burst kick (m/s) | 6 | 0 to 15 |
| Burst (double tap sprint) | Burst sound and screen effect | on | |
| Burst (double tap sprint) | Burst stamina drain (% per second) | 25 | 5 to 100 |
| Burst (double tap sprint) | Stamina needed (%) | 10 | 0 to 100 |
| Burst (double tap sprint) | Cooldown (s) | 0 | 0 to 15 |
| Burst (double tap sprint) | Double sprint stamina (% per second) | 10 | 0 to 50 |
| Sprint build-up | Sprint build-up | on | |
| Sprint build-up | Start speed (x sprint) | 0.50 | 0.2 to 1.0 |
| Sprint build-up | Seconds to full speed | 15 | 1 to 20 |
| Sprint build-up | Curve (1 = even) | 2 | 1 to 4 |
| Sprint build-up | Top speed after build-up (x sprint) | 1.0 | 1.0 to 1.3 |
| Debug | Speed log | off | |

The speed log writes the measured speed, the `MaxSpeed` stat, the build-up and the stamina to the CET game log once per second while sprinting, plus one list of every `MaxSpeed` modifier per game session.

The tier values themselves are in `tools/build_yaml.py`. To change them, edit the tables there and run `python -I -X utf8 tools/build_yaml.py` from the repository folder; it rewrites `package/r6/tweaks/zz_ChromeStride/ChromeStride.yaml`. The script needs only Python 3.

## Status

| Version | Game | Result |
|---|---|---|
| 1.0.0 to 1.1.0 | 2.31 | No written test record. |
| 1.2.0 | 2.31 | Confirmed in game. |
| 1.3.0, 1.3.1 | 2.31 | No written test record. |
| 1.4.0 | 2.31 | Confirmed in game, 2026-10-29, with the speed log on. The result was "works", with the request for a longer build-up that became 1.4.1. |
| 1.4.1 to 1.4.3 | 2.31 | No written test record. 1.4.3 compiles with 0 errors and 5 warnings, with and without Running Man. |
| 1.4.3 | 2.5 | In use in the author's game and working (author's statement, 2026-11-24). No written test record. |

Before the first in-game run, the sprint logic was checked with a small model of the sprint state machine in Python (frame steps at 22 to 25 fps, all four possible orders of this mod's wraps and Running Man's), with 0 failures. That model is not part of this repository.

## Compatibility

| Item | Status | Notes |
|---|---|---|
| Running Man | needed for the burst | The burst is Running Man's double-tap sprint. Its per-frame double sprint cost is set to 0 and charged per second instead. Its stamina perk rules are kept. |
| Walk By Default | recommended | The mod assumes a sprint speed of 7.5 for a new character. |
| Jenkins' Tendons, Leeroy Ligament System, Lynx Paws | kept | Their vanilla effects stay. With "steady bonus" on, Jenkins' bonus stays full while sprinting instead of fading. |
| Other mods that change `MaxSpeed` or the player's speed limits | not tested | This mod raises the caps to 26 m/s and adds one sprint-only modifier. |

## Known issues

- The 94 km/h ceiling is set in the tweak file when the game loads and cannot go higher through the settings.
- Versions 1.4.1 to 1.4.3 have no written test record, and there is no written test on game version 2.5.

## Engineering notes

**Problem 1: higher tiers too fast.** In 1.0.0 to 1.2.0 the higher-tier leg implants gave more speed than the tier table said, about +34 % more than expected.

**Diagnosis.** A dump of every `MaxSpeed` modifier in game showed 8 modifiers of 0.0425 next to 8 of 0.15. TweakXL resolves record inheritance after it reads the YAML files, and in the game's records every higher tier of these implants derives from the tier 2 record and adds to its `OnEquip` list. A package appended to the tier 2 record therefore reached every tier, on top of each tier's own package.

**Fix.** Since 1.3.0 the tier 2 record carries the base package, which reaches every tier through inheritance, and each higher tier carries only the increment (its table value minus the tier 2 value). The sum per tier is the table value. `tools/build_yaml.py` writes these packages, so the tables stay the single place to edit.

**Problem 2: a speed wall at 54 km/h.** With the `MaxSpeed` stat at 22.7 to 26 m/s, the measured speed stayed at 15.0 m/s.

**Diagnosis and fix.** The engine also clamps the player's ground and air speed (15 and 18 m/s in the player record). The tweak file raises both to 26 m/s. In a later in-game test the speed followed the stat up to 25.6 m/s.

**Check.** The generator in `tools/` produces a file identical to the shipped `ChromeStride.yaml`. Version 1.4.0 was confirmed in game with the speed log.

**Rollback.** Each version was kept in its own release folder, so a previous version could be put back. For a user: delete two folders.

## Changelog

See [CHANGELOG.md](CHANGELOG.md). Latest: 1.4.3 (2026-10-29): burst top speed setting.

## Credits and licence

Runs on redscript and TweakXL; the burst uses Running Man. None of them are included here. The 26 m/s cap follows a published measurement of wild cheetahs while hunting (Wilson et al., Nature 2013).

MIT, see [LICENSE](LICENSE). The licence covers my code only. Game names and trademarks belong to their owners.

Built with AI assistance (Claude); designed, tested and maintained by me.
