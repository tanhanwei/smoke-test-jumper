# Smoke Test Jumper

Throwaway Godot 4.7 project that exists to prove one thing end to end:

**scaffold -> headless tune -> headless test -> multi-platform export -> GitHub release**

with no human in the loop and no editor window ever opening.

## The tuning problem

`src/jump_tuning.gd` holds the jump feel constants. They are *not* hand-picked --
they are solved for. The design targets are:

| Target | Value |
|---|---|
| Jump apex | 96 px (3 tiles @ 32px) |
| Time to apex | 0.35 s |

`tools/tune_jump.gd` runs a coarse-to-fine sweep over `(gravity, jump_velocity)`,
simulating the arc with the same discrete 60 Hz integration the real game uses,
and minimises normalised squared error against those targets.

This matters because the analytic answer is *wrong*. Continuous math says
`gravity=1567.35, jump_velocity=-548.57`. Discrete 60 Hz integration actually
lands on `gravity=1542.86, jump_velocity=-557.14` -- a 1.6% gravity error you
would otherwise ship.

## Commands

```bash
GODOT="$HOME/Godot/Godot_v4.7.2-stable_win64_console.exe"

# solve for ideal constants
"$GODOT" --headless --path . --script tools/tune_jump.gd

# verify (exit 0 = pass, 1 = fail)
"$GODOT" --headless --path . --script tests/run_tests.gd

# build
"$GODOT" --headless --path . --export-release "Windows"
"$GODOT" --headless --path . --export-release "macOS"
"$GODOT" --headless --path . --export-release "Linux"
"$GODOT" --headless --path . --export-release "Web"
```

## Builds

| Platform | Artifact | Notes |
|---|---|---|
| Windows | `SmokeTestJumper.exe` | single portable file, pck embedded |
| macOS | `SmokeTestJumper.zip` | universal (Intel + Apple Silicon), **unsigned** |
| Linux | `SmokeTestJumper.x86_64` | single portable binary |
| Web | `web.zip` | needs COOP/COEP headers to run |

macOS is unsigned, so Gatekeeper will block it on first run --
right-click > Open, or `xattr -dr com.apple.quarantine`.
