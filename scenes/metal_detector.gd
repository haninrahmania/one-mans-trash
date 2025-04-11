extends Area2D

@onready var beep = $BeepPlayer
@onready var beep_timer = $BeepTimer
@onready var treasure_container = get_tree().get_current_scene().get_node("TreasureContainer")
@export var level_size = Vector2(2250, 2100)  
@export var margin = 5 

var treasure: Node2D
var distance: float = 0.0  

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	treasure = get_parent().get_node("Treasure")
	beep_timer.timeout.connect(_on_beep_timer_timeout)

		
func _process(delta):
	# Move the detector toward the mouse, clamped to level bounds
	var mouse_pos = get_global_mouse_position()
	var clamped_pos = Vector2(
		clamp(mouse_pos.x, margin, level_size.x - margin),
		clamp(mouse_pos.y, margin, level_size.y - margin)
	)
	global_position = global_position.lerp(clamped_pos, 10 * delta)

	# Find the closest uncollected treasure
	var closest_treasure = null
	var min_distance = INF

	for t in treasure_container.get_children():
		if t.collected:
			continue

		var dist = position.distance_to(t.global_position)
		if dist < min_distance:
			min_distance = dist
			closest_treasure = t

	if closest_treasure:
		handle_beeping(min_distance)
	#else:
		# Use a slower beep when no treasure is nearby
		#handle_beeping(1000)  # Far distance to simulate no target
		
func handle_beeping(distance):
	var beep_interval = clamp(distance / 300.0, 0.2, 1.0)
	beep_timer.wait_time = beep_interval

	if beep_timer.is_stopped():
		beep_timer.start()


func stop_beeping():
	beep_timer.stop()
	beep.stop()

func _on_beep_timer_timeout():
	#var pitch = clamp(1.5 - distance / 300.0, 0.8, 1.2)
	#beep.pitch_scale = pitch
	beep.play()
