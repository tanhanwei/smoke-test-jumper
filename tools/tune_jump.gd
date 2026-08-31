extends SceneTree

## Headless parameter sweep: finds the (gravity, jump_velocity) pair whose
## SIMULATED 60Hz arc best matches the design targets in JumpTuning.
## Analytic solution is only an approximation once you discretise, so we search.
## Run: godot --headless --path . --script tools/tune_jump.gd

func _init() -> void:
    var target_h := JumpTuning.TARGET_APEX_PX
    var target_t := JumpTuning.TARGET_TIME_TO_APEX_S

    # Analytic seed: v = 2h/t, g = v/t
    var seed_v := 2.0 * target_h / target_t
    var seed_g := seed_v / target_t
    print("analytic seed: gravity=%.2f jump_velocity=%.2f" % [seed_g, -seed_v])

    var best_g := seed_g
    var best_v := seed_v
    var best_err := INF

    # Coarse-to-fine search around the seed.
    var g_span := seed_g * 0.25
    var v_span := seed_v * 0.25
    for pass_i in range(4):
        var steps := 40
        var found_g := best_g
        var found_v := best_v
        for i in range(steps + 1):
            var g: float = best_g - g_span + (2.0 * g_span) * float(i) / float(steps)
            for j in range(steps + 1):
                var v: float = best_v - v_span + (2.0 * v_span) * float(j) / float(steps)
                if g <= 0.0 or v <= 0.0:
                    continue
                var r: Dictionary = JumpTuning.simulate(g, -v)
                # Normalised squared error so both targets weigh equally.
                var eh: float = (r["apex_px"] - target_h) / target_h
                var et: float = (r["time_to_apex_s"] - target_t) / target_t
                var err: float = eh * eh + et * et
                if err < best_err:
                    best_err = err
                    found_g = g
                    found_v = v
        best_g = found_g
        best_v = found_v
        g_span *= 0.25
        v_span *= 0.25
        print("pass %d: gravity=%.2f jump_velocity=%.2f err=%.8f" % [pass_i + 1, best_g, -best_v, best_err])

    var final: Dictionary = JumpTuning.simulate(best_g, -best_v)
    print("\n=== TUNED ===")
    print("GRAVITY       = %.2f" % best_g)
    print("JUMP_VELOCITY = %.2f" % -best_v)
    print("-> apex %.2f px (target %.2f)" % [final["apex_px"], target_h])
    print("-> time to apex %.4f s (target %.4f)" % [final["time_to_apex_s"], target_t])
    print("-> airtime %.4f s" % final["airtime_s"])
    quit(0)
