extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


var chain_velocity := Vector2(0, 0)
var has_double_jump_charge := false
var last_on_floor := 0
var last_jump_input := 0
var last_hooked_ms := 0

const config := {
	x_acceleration = 200.0 * 3,
	max_x_speed = 1200.0 * 3,
	max_y_speed = 1000.0 * 3,
	max_y_speed_with_down_pressed = 1500.0 * 3,
	gravity = 50.0 * 3,
	jump_force = 1000.0 * 3,
	squish = .8,
	coyote_time_ms = 200,
	jump_buffering_time_ms = 200,
	disabled_controls_after_tp_ms = 200,
	chain_velocity = 120.0 * 3,
	maintain_momentum_after_hook_ms = 500,
}

var prev := {
	is_on_floor = false,
	hooked = false
}


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				get_tree().reload_current_scene()
			if event.keycode == KEY_P:
				get_tree().quit()
			

var last_teleport_ms := 0



func _physics_process(delta: float) -> void:
	if not $Chain.hooked:
		var walk := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		if walk:
			animated_sprite_2d.rotation = move_toward(
				animated_sprite_2d.rotation,
				atan2(walk, 4),
				delta * 2
			)
			animated_sprite_2d.flip_h = walk > 0
		else:
			animated_sprite_2d.rotation = move_toward(
				animated_sprite_2d.rotation,
				0,
				delta * 4
			)
		if Time.get_ticks_msec() - last_teleport_ms > config.disabled_controls_after_tp_ms:
			if last_hooked_ms + config.maintain_momentum_after_hook_ms < Time.get_ticks_msec() or walk:
				velocity.x = move_toward(velocity.x, walk * config.max_x_speed, config.x_acceleration)
		if Input.is_action_just_pressed("jump"):
			last_jump_input = Time.get_ticks_msec()

		if Time.get_ticks_msec() - last_jump_input < config.jump_buffering_time_ms:
			if Time.get_ticks_msec() - last_on_floor < config.coyote_time_ms || has_double_jump_charge:
				animation_player.play("squish")
				has_double_jump_charge = Time.get_ticks_msec() - last_on_floor < config.coyote_time_ms
				velocity.y = -config.jump_force;
				last_jump_input = 0
		
		if not is_on_floor():
			if Time.get_ticks_msec() - last_teleport_ms > config.disabled_controls_after_tp_ms:
				velocity.y = move_toward(
					velocity.y,
					config.max_y_speed_with_down_pressed if Input.is_action_pressed("down") else config.max_y_speed,
					config.gravity * 2 if Input.is_action_pressed("down") else config.gravity,
				)
		
		if not prev.is_on_floor and is_on_floor():
			animation_player.play("squish")
		if is_on_floor():
			last_on_floor = Time.get_ticks_msec()
		prev.is_on_floor = is_on_floor()

	if $Chain.hooked:
		var chain_vector = $Chain.tip - global_position
		velocity += chain_vector.normalized() * config.chain_velocity
		last_hooked_ms = Time.get_ticks_msec()
	if prev.hooked and not $Chain.hooked:
		has_double_jump_charge = true
	prev.hooked = $Chain.hooked
	move_and_slide()


func _on_teleportable_teleported(get_new_position) -> void:
	var new_params = get_new_position.call(velocity);
	global_position = new_params.new_position
	velocity = new_params.new_velocity
	last_teleport_ms = Time.get_ticks_msec()
	has_double_jump_charge = true
