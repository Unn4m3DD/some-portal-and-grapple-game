extends CollisionObject2D

@export var button: Node2D;
@export var is_inverted: bool
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var preview_1: Sprite2D = $Preview1
@onready var preview_2: Sprite2D = $Preview2


func toggle_door_visibility(new_visibility: bool):
	if new_visibility:
		animation_player.play("close")
	else:
		animation_player.play("open")

func _ready():
	preview_1.visible = false
	preview_2.visible = false
	(button.is_pressed as Signal).connect(on_button_pressed)
	(button.is_not_pressed as Signal).connect(on_button_not_pressed)
	if !is_inverted: 
		toggle_door_visibility(true)

func on_button_pressed():
	toggle_door_visibility(is_inverted)

func on_button_not_pressed():
	toggle_door_visibility(!is_inverted)
