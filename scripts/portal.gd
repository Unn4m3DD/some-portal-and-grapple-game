extends Area2D

var gravity_magnitude: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var other_portal: Node2D = get_node("./%s" % get_meta("other"))

static var portal_mutex := false

func _on_body_entered(player: CharacterBody2D) -> void:
	if portal_mutex:
		return
	portal_mutex = true
	var y_distance := (player.global_position.y - global_position.y)
	var velocity_value := player.velocity.length() + y_distance
	print(y_distance)
	print(player.velocity)
	var player_collider: CollisionShape2D = player.get_node("CollisionShape2D")
	player.position = other_portal.global_position + Vector2.RIGHT.rotated(other_portal.rotation) * player_collider.shape.radius * 20
	player.velocity = Vector2.RIGHT.rotated(other_portal.rotation) * velocity_value

func _on_body_exited(_player: CharacterBody2D) -> void:
	portal_mutex = false
