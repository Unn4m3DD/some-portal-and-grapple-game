extends Node2D

@onready var root := get_node("/root/");
@onready var orange_portal: Area2D = $OrangePortal
@onready var blue_portal: Area2D = $BluePortal

var current_portal := 'orange';

func spawn_portal(new_position: Vector2, new_rotation: float) -> void:
	var new_portal: Area2D
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
