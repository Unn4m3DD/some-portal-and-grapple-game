extends Area2D

@onready var root = get_node("/root/");

var direction := Vector2.ZERO
const speed := 800.0
var box_scene = preload("res://scenes/box.tscn")

func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(_body: Node2D) -> void:
	var box = box_scene.instantiate()
	box.position = global_position
	root.add_child(box)
	queue_free()
