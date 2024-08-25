extends Area2D

@onready var other: Node2D = get_node("./%s" % get_meta("other"))

func _on_body_entered(body: Node2D) -> void:
	body.position = other.global_position
