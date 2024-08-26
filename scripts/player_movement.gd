extends CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# if $Chain.hooked:
# 	$Chain.tip

var chain_velocity := Vector2(0, 0)
var has_double_jump_charge := false
var last_on_floor := 0
var last_jump_input := 0

const config := {
	x_acceleration = 200.0,
	max_x_speed = 800.0,
	max_y_speed = 1000.0,
	gravity = 50.0,
	jump_force = 1000.0,
	squish = .8,
	coyote_time_ms = 100,
	jump_buffering_time_ms = 100,
}

var prev := {
	is_on_floor = false,
}

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				$Chain.shoot(event.position - get_viewport().size * 0.5)
			else:
				$Chain.release()

func _physics_process(_delta: float) -> void:
	var walk := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if walk:
		animated_sprite_2d.rotation = atan2(walk, 4)
		animated_sprite_2d.flip_h = walk > 0
	else:
		animated_sprite_2d.rotation = 0
	velocity.x = move_toward(velocity.x, walk * config.max_x_speed, config.x_acceleration)
	if Input.is_action_just_pressed("jump"):
		last_jump_input = Time.get_ticks_msec()

	if Time.get_ticks_msec() - last_jump_input < config.jump_buffering_time_ms:
		if Time.get_ticks_msec() - last_on_floor < config.coyote_time_ms || has_double_jump_charge:
			animation_player.play("squish")
			has_double_jump_charge = is_on_floor()
			velocity.y = -config.jump_force;
			last_jump_input = 0
	
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, config.max_y_speed, config.gravity)
	
	if not prev.is_on_floor and is_on_floor():
		animation_player.play("squish")
	if is_on_floor():
		last_on_floor = Time.get_ticks_msec()
	prev.is_on_floor = is_on_floor()
	move_and_slide()
