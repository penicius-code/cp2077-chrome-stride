# Changelog

All versions were built on game version 2.31. "Not run in game" means it was not played; "no written test record" means it may have been played, but no result was written down.

## 1.4.3 - 2026-10-29
### Added
- Mod Settings "Burst top speed (km/h)", 40 to 94, changeable while playing.

Not run in game.

## 1.4.2 - 2026-10-29
### Changed
- The normal sprint is capped at 50 km/h; the burst still goes up to 94 km/h.
- Speed limits in the settings and the speed log are in km/h.
- Build-up starts at 0.50 and takes 15 s, curve 2.

Not run in game.

## 1.4.1 - 2026-10-29
### Changed
- Build-up over 10 s instead of 6.

Not run in game.

## 1.4.0 - 2026-10-29
### Changed
- Sprint build-up on by default and reworked: it starts slower, follows the measured speed and cannot run more than 1.5 s ahead of it.
### Added
- Jenkins' Tendons steady bonus: its bonus stays full while sprinting.

Confirmed in game.

## 1.3.1 - 2026-10-27
### Fixed
- The burst fires again on every trigger Running Man accepts; 1.3.0 had required a different input and the double tap did not fire.

## 1.3.0 - 2026-10-27
### Changed
- Tier bonuses as a base on the tier 2 record plus increments on the higher tiers (TweakXL record inheritance).
- The burst lasts until stamina runs out, with no cooldown; per-second stamina drains instead of a per-frame cost.
- The carry penalty moved into the script.

## 1.2.0 - 2026-10-27
### Added
- Engine ground and air speed limits raised to 26 m/s; sprint and carry limits; modifier dump in the speed log.
### Changed
- Sprinting has a real stamina cost; a stronger burst.

Confirmed in game.

## 1.1.0 - 2026-10-27
### Added
- Sprint stamina and the winded state; burst with kick and effects; speed log.

## 1.0.0 - 2026-10-27
- First version: tier bonuses on the leg implants, carry penalty, 26 m/s speed cap; optional build-up and burst.
