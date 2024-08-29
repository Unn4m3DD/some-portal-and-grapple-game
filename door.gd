extends CollisionObject2D

@export var button: Node2D;
@export var is_inverted: bool

func toggle_door_visibility(visible: bool):
	set_collision_layer_value(1, is_inverted)
	for child in get_children():
		if child.name.contains("DoorMiddle"):
			child.visible = visible


func _ready():
	(button.is_pressed as Signal).connect(on_button_pressed)
	(button.is_not_pressed as Signal).connect(on_button_not_pressed)
	toggle_door_visibility(!is_inverted)
	
func on_button_pressed():
	toggle_door_visibility(is_inverted)

func on_button_not_pressed():
	toggle_door_visibility(!is_inverted)
