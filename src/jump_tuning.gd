class_name JumpTuning
extends RefCounted

## Single source of truth for jump feel.
## These values are produced by tools/tune_jump.gd, not hand-picked.

const GRAVITY: float = 1542.86
const JUMP_VELOCITY: float = -557.14
const RUN_SPEED: float = 220.0

## Design targets the tuner solves against.
const TARGET_APEX_PX: float = 96.0     # 3 tiles @ 32px
const TARGET_TIME_TO_APEX_S: float = 0.35

## Simulate a jump with discrete 60Hz integration.
## Returns {apex_px, time_to_apex_s, airtime_s}.
static func simulate(gravity: float, jump_velocity: float, step: float = 1.0 / 60.0) -> Dictionary:
    var y := 0.0
    var vy := jump_velocity
    var t := 0.0
    var apex := 0.0
    var t_apex := 0.0
    var guard := 0
    while guard < 100000:
        guard += 1
        vy += gravity * step
        y += vy * step
        t += step
        if -y > apex:
            apex = -y
            t_apex = t
        if y >= 0.0:
            break
    return {"apex_px": apex, "time_to_apex_s": t_apex, "airtime_s": t}
