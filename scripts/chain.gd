extends Node2D
@onready var timer: Timer = $Timer

@onready var links := $Links
var direction := Vector2(0, 0)
var tip := Vector2(0, 0)

const SPEED := 50

var flying := false
var hooked := false

func shoot(dir: Vector2) -> void:
	direction = dir.normalized()
	flying = true
	tip = self.global_position

func release() -> void:
	flying = false
	hooked = false
	timer.stop()

func _process(_delta: float) -> void:
	self.visible = flying or hooked
	if not self.visible:
		return
	var tip_loc = to_local(tip)
	links.rotation = self.position.angle_to_point(tip_loc) + deg_to_rad(90)
	$Tip.rotation = self.position.angle_to_point(tip_loc) + deg_to_rad(90)
	links.position = tip_loc
	links.region_rect.size.y = tip_loc.length()

func _physics_process(_delta: float) -> void:
	$Tip.global_position = tip
	if flying:
		if $Tip.move_and_collide(direction * SPEED):
			timer.start()
			hooked = true
			flying = false
	tip = $Tip.global_position


func _on_timer_timeout() -> void:
	release()
