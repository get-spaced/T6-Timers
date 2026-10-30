# T6 Zombies Timer HUD

A lightweight GSC timer HUD for **Call of Duty: Black Ops II Zombies** on **Plutonium T6**. Track your total game time, the current round's duration, and cumulative end-of-round splits directly in-game.

## Features

- **Game timer** — counts upward from the start of the tracked session.
- **Round timer** — resets at the start of each round and holds its final time when the round ends.
- **Split timer** — records the total elapsed game time when each round finishes, alongside the completed round number.
- **Compact HUD** — three color-coded labels in the upper-left area of the screen.
- **Readable timestamps** — displays `M:SS`, switching to `H:MM:SS` after one hour.
- **Automatic operation** — uses Zombies round events; no chat commands or manual timer controls are needed.

## HUD Preview

```text
GAME     12:34
ROUND     1:04
SPLIT    R5 - 11:30
```

| Label | Meaning |
| --- | --- |
| **GAME** | Total elapsed time since the game timer began tracking. |
| **ROUND** | Elapsed time for the current round, or its final duration after the round ends. |
| **SPLIT** | Total elapsed game time at the end of the last completed round, prefixed by its round number. |

The split is a **cumulative timestamp**, not the duration of an individual round. Before the first round finishes, it displays `--:--`.

## Installation

1. Save the script's GSC source as `timers.gsc` (or download that file from this repository once added).
2. Open the Plutonium T6 Zombies scripts folder:

   ```text
   %localappdata%\Plutonium\storage\t6\scripts\zm
   ```

3. Place `timers.gsc` in that folder. Create the `scripts\zm` folders if necessary.
4. Launch Plutonium T6 Zombies and start a new game. The HUD initializes automatically.

For a dedicated server, install the GSC in the server's equivalent `Plutonium/storage/t6/scripts/zm` directory and restart the server.

For more information, see the [official Plutonium GSC loading documentation](https://plutonium.pw/docs/client/t6/loading-and-compiling-gsc/).

## How It Works

The script listens for `start_of_round` and `end_of_round` events:

- At the beginning of a round, it resets and starts the **ROUND** timer.
- At the end of a round, it stores that round's final duration and updates **SPLIT** with the round number and cumulative game time.
- **GAME** continues to run independently of round transitions.

The HUD is created after the initial black screen has passed. Game time is anchored to the first observed round start or HUD initialization, whichever occurs first.

## Customization

You can adjust the included GSC source to change the HUD appearance:

| Setting | Location in source |
| --- | --- |
| Vertical spacing | `create_timer_hud()` / `create_timer_element()` calls |
| Horizontal position | `hud setpoint(...)` in `create_timer_element()` |
| Font and size | `createServerFontString("objective", 1.5)` |
| Label colors and wording | `"^2GAME"`, `"^3ROUND"`, and `"^5SPLIT"` |
| Time display format | `format_timer_time(milliseconds)` |

## Compatibility

- **Game:** Call of Duty: Black Ops II Zombies
- **Platform:** Plutonium T6
- **Language:** GSC
- **Script type:** Zombies-only (`scripts/zm`)

## Notes

- The timer is informational and does not modify round progression, zombies, perks, or weapons.
- The final round duration remains displayed until the next round begins.
- Split information reflects the **most recently completed round**.
- Timer values are based on the game's `gettime()` clock and are not persisted between sessions.

## Credits

Built for the Plutonium T6 Zombies modding community.
