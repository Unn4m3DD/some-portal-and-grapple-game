extends Node2D

@onready var root := get_node("/root/");
@onready var orange_portal: Area2D = $OrangePortal
@onready var blue_portal: Area2D = $BluePortal


func spawn_portal(current_portal: String, new_position: Vector2, new_rotation: float, can_orange_portal: bool, can_blue_portal: bool) -> void:
	var new_portal: Area2D
	if not can_orange_portal and current_portal == 'orange':
		return
	if not can_blue_portal and current_portal == 'blue':
		return

	match current_portal:
		'orange':
			new_portal = orange_portal
			current_portal = 'blue'
		'blue':
			new_portal = blue_portal
			current_portal = 'orange'

	var collision_shape: CollisionShape2D = new_portal.get_node("CollisionShape2D")
	new_portal.position =	new_position + Vector2.RIGHT.rotated(new_rotation) * collision_shape.shape.size.x * .2 * collision_shape.scale.x * new_portal.scale.x
	new_portal.rotation = new_rotation
	var collision_shape2d: AnimationPlayer = new_portal.get_node("AnimationPlayer")
	collision_shape2d.play("portal_spawn")
