
extends Camera2D

const DEAD_ZONE = 160

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: 
		var mouse = event.position - get_viewport().size * 0.5
		if mouse.length() < DEAD_ZONE:
			self.position = Vector2(0,0)
		else:
			self.position = mouse.normalized() * (mouse.length() - DEAD_ZONE) * 0.2
