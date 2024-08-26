extends Area2D

@onready var root := get_node("/root/");
@onready var portal_manager := $ / root / Level / PortalManager
@onready var ray_cast_2d := $RayCast2D


var direction := Vector2.ZERO
const speed := 2500.0
var box_scene := preload("res://scenes/box.tscn")

func _process(delta: float) -> void:
	position += direction * speed * delta
	if ray_cast_2d.is_colliding():
		var normal: Vector2 = ray_cast_2d.get_collision_normal()
		rotation = atan2(normal.y, normal.x)
		portal_manager.spawn_portal(ray_cast_2d.get_collision_point(), rotation)
		queue_free()
