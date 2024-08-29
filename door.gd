extends CollisionObject2D

@export var button: Node2D;
@export var is_inverted: bool
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func toggle_door_visibility(new_visibility: bool):
	if new_visibility:
		animation_player.play("close")
	else:
		animation_player.play("open")

func _ready():
	(button.is_pressed as Signal).connect(on_button_pressed)
	(button.is_not_pressed as Signal).connect(on_button_not_pressed)
	if !is_inverted: 
		toggle_door_visibility(true)

func on_button_pressed():
	toggle_door_visibility(is_inverted)

func on_button_not_pressed():
	toggle_door_visibility(!is_inverted)
