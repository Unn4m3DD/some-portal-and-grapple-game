extends Area2D

@onready var highlightable: CanvasItem = $Highlightable

var is_highlightable = false
var is_mouse_hover = false

var is_highlighted = false

func highlight(on: bool):
	is_mouse_hover = on
	
func _process(_delta):
	if is_mouse_hover and is_highlightable:
		highlightable.material = preload("res://materials/highlight.tres")
		is_highlighted = true
	else:
		highlightable.material = null
		is_highlighted = false
	

func _on_area_entered(_area: Area2D) -> void:
	is_highlightable = true

func _on_area_exited(_area: Area2D) -> void:
	is_highlightable = false
