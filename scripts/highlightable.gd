extends Area2D

@onready var highlightable: Sprite2D = $Highlightable

var is_highlightable = false
var is_mouse_hover = false

func highlight(on: bool):
	is_mouse_hover = on
	
func _process(_delta):
	if is_mouse_hover and is_highlightable:
		highlightable.material = preload("res://materials/highlight.tres")
	else:
		highlightable.material = null
	

func _on_area_entered(area: Area2D) -> void:
	is_highlightable = true

func _on_area_exited(area: Area2D) -> void:
	is_highlightable = false
