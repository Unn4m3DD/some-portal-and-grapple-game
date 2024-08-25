extends Area2D

@onready var other: Node2D = get_node("./%s" % get_meta("other"))

static var portal_mutex = false

func _on_body_entered(body: Node2D) -> void:
	if portal_mutex:
		return
	portal_mutex = true
	body.position = other.global_position

func _on_body_exited(_body: Node2D) -> void:
	portal_mutex = false
