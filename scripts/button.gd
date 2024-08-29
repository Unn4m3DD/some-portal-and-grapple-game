extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D

signal is_pressed
signal is_not_pressed

func _ready():
	animation_player.play("go_up")

var is_down

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if(area_2d.has_overlapping_bodies() and not is_down):
		is_pressed.emit()
		animation_player.play("go_down")
		is_down = true


func _on_area_2d_body_exited(_body: Node2D) -> void:
	if(!area_2d.has_overlapping_bodies() and is_down):
		is_not_pressed.emit()
		animation_player.play("go_up")
		is_down = false
