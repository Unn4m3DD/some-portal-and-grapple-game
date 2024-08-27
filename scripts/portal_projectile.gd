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
		var other_body: TileMapLayer = ray_cast_2d.get_collider()
		var tile_data = other_body.get_cell_tile_data(other_body.get_coords_for_body_rid(ray_cast_2d.get_collider_rid()))
		if not tile_data:
			return
		var can_orange_portal = tile_data.get_custom_data("can_orange_portal") || false
		var can_blue_portal = tile_data.get_custom_data("can_blue_portal") || false
		
		var normal: Vector2 = ray_cast_2d.get_collision_normal()
		rotation = atan2(normal.y, normal.x)
		portal_manager.spawn_portal(ray_cast_2d.get_collision_point(), rotation, can_orange_portal, can_blue_portal)
		queue_free()
