extends SceneTree

## Headless test suite. Exit 0 = all pass, 1 = failure.
## Run: godot --headless --path . --script tests/run_tests.gd

var _failures: int = 0
var _checks: int = 0

func _assert(cond: bool, label: String, detail: String = "") -> void:
    _checks += 1
    if cond:
        print("  PASS  %s" % label)
    else:
        _failures += 1
        print("  FAIL  %s %s" % [label, detail])

func _assert_near(actual: float, expected: float, tol: float, label: String) -> void:
    _assert(absf(actual - expected) <= tol, label,
        "(got %.3f, want %.3f +/- %.3f)" % [actual, expected, tol])

func _init() -> void:
    print("== jump physics ==")
    var r: Dictionary = JumpTuning.simulate(JumpTuning.GRAVITY, JumpTuning.JUMP_VELOCITY)

    _assert_near(r["apex_px"], JumpTuning.TARGET_APEX_PX, 2.0, "apex height hits design target")
    _assert_near(r["time_to_apex_s"], JumpTuning.TARGET_TIME_TO_APEX_S, 0.02, "time to apex hits design target")
    _assert(r["airtime_s"] > r["time_to_apex_s"], "airtime exceeds time-to-apex")
    _assert_near(r["airtime_s"], r["time_to_apex_s"] * 2.0, 0.05, "jump arc is symmetric")

    print("== invariants ==")
    _assert(JumpTuning.JUMP_VELOCITY < 0.0, "jump velocity is negative (up)")
    _assert(JumpTuning.GRAVITY > 0.0, "gravity is positive (down)")
    _assert(JumpTuning.RUN_SPEED > 0.0, "run speed is positive")

    print("== monotonicity ==")
    var weak: Dictionary = JumpTuning.simulate(JumpTuning.GRAVITY, JumpTuning.JUMP_VELOCITY * 0.5)
    var strong: Dictionary = JumpTuning.simulate(JumpTuning.GRAVITY, JumpTuning.JUMP_VELOCITY * 1.5)
    _assert(weak["apex_px"] < r["apex_px"], "weaker jump goes lower")
    _assert(strong["apex_px"] > r["apex_px"], "stronger jump goes higher")

    var heavy: Dictionary = JumpTuning.simulate(JumpTuning.GRAVITY * 2.0, JumpTuning.JUMP_VELOCITY)
    _assert(heavy["apex_px"] < r["apex_px"], "higher gravity reduces apex")

    print("\n%d checks, %d failures" % [_checks, _failures])
    if _failures > 0:
        print("TESTS FAILED")
        quit(1)
    print("TESTS PASSED")
    quit(0)
