extends Node2D

@onready var root = get_node("/root/");
@onready var orange_portal = $OrangePortal
@onready var blue_portal = $BluePortal

var current_portal = 'orange';

func spawn_portal(new_position: Vector2) -> void:
	match current_portal:
		'orange':
			orange_portal.position = new_position
			current_portal = 'blue'
		'blue':
			blue_portal.position = new_position
			current_portal = 'orange'
