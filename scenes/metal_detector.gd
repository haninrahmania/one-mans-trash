extends Area2D

@onready var beep = $BeepPlayer
@onready var beep_timer = $BeepTimer
@export var level_size = Vector2(2250, 2100)  
@export var margin = 5 

var treasure: Node2D
var distance: float = 0.0  

func _ready():
	treasure = get_parent().get_node("Treasure")
	beep_timer.timeout.connect(_on_beep_timer_timeout)

func _process(delta):
	position = get_global_mouse_position()
	var mouse_pos = get_global_mouse_position()

	# Clamp the position within the level bounds
	var clamped_pos = Vector2(
		clamp(mouse_pos.x, margin, level_size.x - margin),
		clamp(mouse_pos.y, margin, level_size.y - margin)
	)

	global_position = global_position.lerp(clamped_pos, 10 * delta)

	if treasure and not treasure.collected:
		distance = position.distance_to(treasure.global_position)

		# Convert distance to interval: closer = faster beeps
		var interval = clamp(distance / 300.0, 0.2, 1.0)
		beep_timer.wait_time = interval

func _on_beep_timer_timeout():
	#var pitch = clamp(1.5 - distance / 300.0, 0.8, 1.2)
	#beep.pitch_scale = pitch
	beep.play()
