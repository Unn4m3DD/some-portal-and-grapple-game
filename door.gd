extends CollisionObject2D

@export var button: Node2D;
@export var is_inverted: bool

func _ready():
	(button.is_pressed as Signal).connect(on_button_pressed)
	(button.is_not_pressed as Signal).connect(on_button_not_pressed)
	
func on_button_pressed():
	set_collision_layer_value(1, is_inverted)

func on_button_not_pressed():
	set_collision_layer_value(1, !is_inverted)
