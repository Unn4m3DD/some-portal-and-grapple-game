extends StaticBody2D

var direction := Vector2.ZERO
const speed := 10.0
var box_scene := preload("res://scenes/box.tscn")


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	var box := box_scene.instantiate()
	box.position = position
	body.add_child(box)
	queue_free()
