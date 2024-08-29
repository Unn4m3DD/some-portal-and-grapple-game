extends RigidBody2D

@onready var highlighter: Area2D = $Highlighter

@onready var player_hand = $/root/Level/Player/Hand/PortalGun
@onready var timer: Timer = $Timer


var pull_force := 10.0

var is_following := false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_E:
			if highlighter.is_highlighted:
				is_following = true
			elif is_following:
				is_following = false
				
func _ready():
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	set_collision_layer_value(1, true)

func _physics_process(_delta: float) -> void:
	if is_following:
		gravity_scale = 0
		var cube_to_hand_vector = player_hand.global_position - global_position
		if cube_to_hand_vector.length() > 1.:
			linear_velocity = cube_to_hand_vector * pull_force
		else:
			linear_velocity = Vector2.ZERO
		set_collision_layer_value(1, false)
	else:
		gravity_scale = 1
		timer.start()
	


func _on_teleportable_teleported(get_new_position):
	var new_params = get_new_position.call(linear_velocity);
	global_position = new_params.new_position
	linear_velocity = new_params.new_velocity
	is_following = false
