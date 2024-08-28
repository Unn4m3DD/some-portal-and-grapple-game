extends Area2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()


func _on_area_entered(area: Area2D) -> void:
	if 'highlight' in area:
		area.highlight(true)


func _on_area_exited(area: Area2D) -> void:
	if 'highlight' in area:
		area.highlight(false)
