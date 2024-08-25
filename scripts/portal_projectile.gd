extends Area2D

@onready var root = get_node("/root/");
@onready var portal_manager: Node2D = $/root/Level/PortalManager


var direction := Vector2.ZERO
const speed := 800.0
var box_scene = preload("res://scenes/box.tscn")

func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(_body: Node2D) -> void:
	portal_manager.spawn_portal(global_position)	
	queue_free()
