extends Node

@onready var ray_right1: RayCast2D = $RayCasts/RayRight1
@onready var ray_left1: RayCast2D = $RayCasts/RayLeft1
@onready var ray_top1: RayCast2D = $RayCasts/RayTop1
@onready var ray_bottom1: RayCast2D = $RayCasts/RayBottom1

@onready var ray_right2: RayCast2D = $RayCasts/RayRight2
@onready var ray_left2: RayCast2D = $RayCasts/RayLeft2
@onready var ray_top2: RayCast2D = $RayCasts/RayTop2
@onready var ray_bottom2: RayCast2D = $RayCasts/RayBottom2

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

	
@export_range(0, 1000) var disabled_controls_after_tp_ms := 200
@export_range(15, 35) var distance_to_portal_before_tp := 25;
@export_range(0, 100) var teleport_offset := 30

signal teleported(get_new_position)

@export var collision_shape_2d: CollisionShape2D
@onready var collider_initial_position: Vector2 = collision_shape_2d.position

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
					if distance > distance_to_portal_before_tp:
						collision_shape_2d.position = collider_initial_position + ray.target_position.normalized() * (distance - ray.target_position.length())
					elif not teleport_mutex[ray_key] and not teleport_mutex[opposite[ray_key]]:
						var current_portal = ray.get_collider();
						var other_portal = current_portal.other_portal;
						collision_shape_2d.position = \
							collider_initial_position + \
							(ray.target_position.normalized() * (distance - ray.target_position.length())) \
							.rotated(current_portal.rotation - other_portal.rotation)
						teleport_mutex[opposite[ray_key]] = true
						teleport_mutex[ray_key] = true
						teleported.emit(
							func(prev_velocity: Vector2):
								var new_velocity = prev_velocity.length() * Vector2.RIGHT.rotated(other_portal.rotation)
								return {
									new_position = other_portal.global_position + new_velocity.normalized() * teleport_offset,
									new_velocity = new_velocity,	
								}
						)
			else:
				teleport_mutex[ray_key] = false
	
	if no_colision:
		collision_shape_2d.position = Vector2(
			move_toward(collision_shape_2d.position.x, collider_initial_position.x, 1),
			move_toward(collision_shape_2d.position.y, collider_initial_position.y, 1),
		)
