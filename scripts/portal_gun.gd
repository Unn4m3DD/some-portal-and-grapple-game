extends Node2D

@onready var root := get_node("/root/");

@onready var player := $".."
@onready var portal_gun_container := $"."
@onready var portal_gun := $"./portal_gun"

const portal_projectile_scene := preload("res://scenes/portal_projectile.tscn")


func _process(_delta: float) -> void:
	var mouse_vector = (get_global_mouse_position() - player.position).normalized()
	portal_gun_container.rotation = (acos(mouse_vector.dot(Vector2.RIGHT))) * sign(mouse_vector.y)

	
func _input(event: InputEvent) -> void:
	var mouse_vector = (get_global_mouse_position() - player.position).normalized()
	var mouse_rotation = (acos(mouse_vector.dot(Vector2.RIGHT))) * sign(mouse_vector.y)
	var direction := Vector2.RIGHT.rotated(mouse_rotation)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				var portal_projectile := portal_projectile_scene.instantiate()
				portal_projectile.position = player.global_position
				portal_projectile.rotation = atan2(direction.y, direction.x)
				portal_projectile.direction = direction
				portal_projectile.portal_color = 'blue' if event.button_index == MOUSE_BUTTON_LEFT else 'orange'
				root.add_child(portal_projectile)
