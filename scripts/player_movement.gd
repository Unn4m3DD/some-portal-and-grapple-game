extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var ray_right1: RayCast2D = $RayCasts/RayRight1
@onready var ray_left1: RayCast2D = $RayCasts/RayLeft1
@onready var ray_top1: RayCast2D = $RayCasts/RayTop1
@onready var ray_bottom1: RayCast2D = $RayCasts/RayBottom1

@onready var ray_right2: RayCast2D = $RayCasts/RayRight2
@onready var ray_left2: RayCast2D = $RayCasts/RayLeft2
@onready var ray_top2: RayCast2D = $RayCasts/RayTop2
@onready var ray_bottom2: RayCast2D = $RayCasts/RayBottom2
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var collider_initial_position: Vector2 = collision_shape_2d.position

@onready var rays = {
	right = [ray_right1, ray_right2],
	left = [ray_left1, ray_left2],
	top = [ray_top1, ray_top2],
	bottom = [ray_bottom1, ray_bottom2],
}
var teleport_mutex = {
	right = false,
	left = false,
	top = false,
	bottom = false,
}
var opposite = {
	right = 'left',
	left = 'right',
	top = 'bottom',
	bottom = 'top',
}


var chain_velocity := Vector2(0, 0)
var has_double_jump_charge := false
var last_on_floor := 0
var last_jump_input := 0

const config := {
	x_acceleration = 200.0,
	max_x_speed = 800.0,
	max_y_speed = 1000.0,
	max_y_speed_with_down_pressed = 1500.0,
	gravity = 50.0,
	jump_force = 1000.0,
	squish = .8,
	coyote_time_ms = 200,
	jump_buffering_time_ms = 200,
	distance_to_portal_before_tp = 25,
	disabled_controls_after_tp_ms = 200,
	chain_velocity = 100.0,
}

var prev := {
	is_on_floor = false,
}


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_ESCAPE:
				get_tree().reload_current_scene()
			if event.keycode == KEY_P:
				get_tree().quit()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				var mouse_vector = (get_global_mouse_position() - position).normalized()
				$Chain.shoot(mouse_vector)
			else:
				$Chain.release()

var last_teleport_ms := 0

func _process(_delta: float) -> void:
	var no_colision = true
	for ray_key in rays:
		for ray in rays[ray_key]:
			if ray.is_colliding():
				no_colision = false
				var colision_ray = ray.get_collision_point() - ray.global_position
				var portal_is_parallel_to_ray = is_zero_approx(Vector2.RIGHT.rotated(ray.get_collider().rotation).cross(colision_ray))
				if portal_is_parallel_to_ray:
					var distance = ray.get_collision_point().distance_to(ray.global_position)
					if distance > config.distance_to_portal_before_tp:
						collision_shape_2d.position = collider_initial_position + ray.target_position.normalized() * (distance - ray.target_position.length())
					elif not teleport_mutex[ray_key] and not teleport_mutex[opposite[ray_key]]:
						var current_portal = ray.get_collider();
						var other_portal = current_portal.other_portal
						velocity = velocity.length() * Vector2.RIGHT.rotated(other_portal.rotation)
						collision_shape_2d.position = \
							collider_initial_position + \
							(ray.target_position.normalized() * (distance - ray.target_position.length())) \
							.rotated(current_portal.rotation - other_portal.rotation)
						last_teleport_ms = Time.get_ticks_msec()
						teleport_mutex[opposite[ray_key]] = true
						teleport_mutex[ray_key] = true
						global_position = other_portal.global_position + velocity.normalized() * 100
						has_double_jump_charge = true
			else:
				teleport_mutex[ray_key] = false
	
	if no_colision:
		collision_shape_2d.position = Vector2(
			move_toward(collision_shape_2d.position.x, collider_initial_position.x, 1),
			move_toward(collision_shape_2d.position.y, collider_initial_position.y, 1),
		)

func _physics_process(_delta: float) -> void:
	var walk := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if walk:
		animated_sprite_2d.rotation = atan2(walk, 4)
		animated_sprite_2d.flip_h = walk > 0
	else:
		animated_sprite_2d.rotation = 0
	if Time.get_ticks_msec() - last_teleport_ms > config.disabled_controls_after_tp_ms:
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
	move_and_slide()
