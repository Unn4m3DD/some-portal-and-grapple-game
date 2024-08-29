extends ShapeCast2D


@onready var ray_targets = {
	right = target_position,
	down = target_position.rotated(deg_to_rad(90)),
	left = target_position.rotated(deg_to_rad(180)),
	up = target_position.rotated(deg_to_rad(270)),
}
var ray_dir = ""
static var teleport_mutex = {
	right = false,
	left = false,
	top = false,
	bottom = false,
}

	
var dive_into_portal_distance := 0
var teleport_exit_offset = 200;
var min_out_speed := 1200.0
var collider_speed := 100
signal teleported(get_new_position)

@export var collision_shape_2d: CollisionShape2D
@onready var collider_initial_position: Vector2 = collision_shape_2d.position

func _ready() -> void:
	if !String(get_path()).contains("ShapeCast2D"):
		for ray_key in ray_targets:
			var new_ray = duplicate();
			new_ray.target_position = ray_targets[ray_key]
			new_ray.ray_dir = ray_key
			add_sibling.call_deferred(new_ray)
		queue_free()

func can_teleport() -> bool:
	for ray_key in teleport_mutex:
		if teleport_mutex[ray_key]:
			return false
	return true

func _process(_delta: float) -> void:
	force_shapecast_update()
	if !is_colliding():
		teleport_mutex[ray_dir] = false
		return
	var ray_vector := target_position - position
	var collision_index: int = floor(collision_result.size() / 2.);
	var portal := get_collider(collision_index)
	if not 'other_portal' in portal: return
	var other_portal = portal.other_portal
	var portal_normal := Vector2.RIGHT.rotated(portal.rotation)
	var portal_is_parallel_to_ray := abs(portal_normal.rotated(PI).angle_to(ray_vector)) as float < PI / 4
	if !portal_is_parallel_to_ray: return
	var collision_point := get_collision_point(collision_index)
	var collision_distance := collision_point.distance_to(global_position) * sign(ray_vector.dot(collision_point - global_position)) as int
	var parent_collision_shape_offset_ammount: int = max(target_position.length() - collision_distance, 0)
	var parent_collision_shape_offset := parent_collision_shape_offset_ammount * portal_normal
	
	collision_shape_2d.position = collider_initial_position + parent_collision_shape_offset * 1.1
	if ray_dir == 'down':
		print(can_teleport())
	if -collision_distance > dive_into_portal_distance:
		collision_shape_2d.position = collider_initial_position \
			+ parent_collision_shape_offset.rotated(other_portal.rotation - portal.rotation) * 2
		print(Vector2.RIGHT.rotated(other_portal.rotation) * teleport_exit_offset)
		teleported.emit(
			func(prev_velocity: Vector2):
				var new_velocity = max(prev_velocity.length(), min_out_speed) * Vector2.RIGHT.rotated(other_portal.rotation)
				print( teleport_exit_offset)
				return {
					new_position = other_portal.global_position + Vector2.RIGHT.rotated(other_portal.rotation) * teleport_exit_offset,
					new_velocity = new_velocity,
				}
		)
