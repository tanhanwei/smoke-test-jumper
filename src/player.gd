extends CharacterBody2D

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += JumpTuning.GRAVITY * delta
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JumpTuning.JUMP_VELOCITY
    var dir := Input.get_axis("ui_left", "ui_right")
    velocity.x = dir * JumpTuning.RUN_SPEED
    move_and_slide()
