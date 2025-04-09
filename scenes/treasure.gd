extends Node2D

@onready var sand_chunks = $SandChunks.get_children()
@onready var treasure_sprite = $TreasureSprite
@onready var area = $Area2D
var collected := false
signal treasure_collected



var chunk_index := 0
var dug := false
var digging_started := false  # Track if first dig has started

func _ready():
	treasure_sprite.visible = false
	for chunk in sand_chunks:
		chunk.visible = false  # Hide treasure at the start

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Clicked on treasure area")
		dig()

func dig():
	if not digging_started:
		digging_started = true  # First dig attempt
		$DigSound.play()
		for chunk in sand_chunks:
			chunk.visible = true
		treasure_sprite.visible = true
		
	

	if dug:
		#if $DigSound.playing:
			#$DigSound.stop()
		return

	if chunk_index < sand_chunks.size():
		#sand_chunks[chunk_index].queue_free()
		var chunk = sand_chunks[chunk_index]
		throw_chunk(chunk)
		chunk_index += 1
		# Play dig sound
		$DigSound.stop()
		$DigSound.play()
	else:
		dug = true
		$TreasureSound.play()
		print("🎉 Treasure fully uncovered!")
		suck_treasure_into_inventory()
		collected = true

		
func throw_chunk(chunk: Node2D):
	var tween = create_tween()

	var start_pos = chunk.position
	var peak_pos = start_pos + Vector2(randf_range(-30, 30), -40)  # Go slightly up and to the side
	var end_pos = start_pos + Vector2(randf_range(-60, 60), 30)    # End slightly below, simulating gravity

	# First arc (up)
	tween.tween_property(chunk, "position", peak_pos, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Then arc down to landing
	tween.tween_property(chunk, "position", end_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Fade out a little after landing
	tween.tween_property(chunk, "modulate:a", 0.0, 0.2).set_delay(0.3)

	# Cleanup
	tween.tween_callback(Callable(chunk, "queue_free"))
	
func suck_treasure_into_inventory():
	var tween = create_tween()

	var screen_size = get_viewport_rect().size
	var target_pos = to_local(Vector2(screen_size.x / 2, screen_size.y - 100))


	# Lift slightly first
	var lift_pos = treasure_sprite.position + Vector2(0, -30)
	tween.tween_property(treasure_sprite, "position", lift_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Then zip into inventory
	tween.tween_property(treasure_sprite, "position", target_pos, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	# Shrink and fade for flair
	tween.tween_property(treasure_sprite, "scale", Vector2(0.2, 0.2), 0.4)
	tween.tween_property(treasure_sprite, "modulate:a", 0.0, 0.4)

	# Optionally queue_free or trigger inventory logic
	tween.tween_callback(func(): treasure_sprite.queue_free())
	
func collect():
	collected = true
	emit_signal("treasure_collected")
	queue_free()
