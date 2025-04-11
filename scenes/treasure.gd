extends Node2D

@onready var sand_chunks = $SandChunks.get_children()
@onready var treasure_sprite = $TreasureSprite
@onready var area = $Area2D
@export var item_name: String
var collected := false
signal treasure_collected


var camera: Camera2D = null 

var chunk_index := 0
var dug := false
var digging_started := false  # Track if first dig has started

func _ready():
	treasure_sprite.visible = false
	for chunk in sand_chunks:
		chunk.visible = false  # Hide treasure at the start
		
	await get_tree().process_frame
	camera = get_viewport().get_camera_2d()
	if camera == null:
		print("⚠️ No Camera2D found in the current viewport.")

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
	if camera == null:
		print("Camera not set on treasure!")
		return

	var tween = create_tween()

	var screen_size = get_viewport_rect().size
	var screen_target = Vector2(screen_size.x / 2, screen_size.y - 100)
	var world_target = camera.get_screen_transform().affine_inverse() * screen_target

	var local_target = to_local(world_target)

	var lift_pos = treasure_sprite.position + Vector2(0, -30)
	tween.tween_property(treasure_sprite, "position", lift_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property(treasure_sprite, "position", local_target, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(treasure_sprite, "scale", Vector2(0.2, 0.2), 0.4)
	tween.tween_property(treasure_sprite, "modulate:a", 0.0, 0.4)

	tween.tween_callback(Callable(self, "collect"))
	
func collect():
	collected = true
	emit_signal("treasure_collected")
	Inventory.add_item(item_name) 
	print("Collect called, item:", item_name)
	Inventory.print_inventory()
	# Update label
	var ui = get_tree().root.get_node("BeachLevel") 
	ui.update_inventory_count()
	ui.show_treasure_popup(item_name)
	queue_free()
	
	var total_items_needed:= 15
	
	if Inventory.get_total_item_count() >= total_items_needed:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")
