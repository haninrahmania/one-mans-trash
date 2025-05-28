extends Node2D

@onready var count_label = $UI/InventoryIcon/CountLabel
@onready var inventory_icon = $UI/InventoryIcon
@onready var pause_screen = $UI/PauseScreen
@export var treasure_scenes: Array[PackedScene] = [] 
@export var num_treasures: int = 10
@onready var treasure_container = $TreasureContainer
@onready var inventory_ui = $UI/InventoryUI
@onready var item_list_container = $UI/InventoryUI/ScrollContainer/VBoxContainer
var inventory_visible := false
var label_settings = preload("res://new_label_settings.tres")
var is_paused = false


func _ready():
	spawn_treasures()
	update_inventory_count()
	inventory_ui.visible = false
	pause_screen.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_screen.visible = false
	
func show_treasure_popup(item_name: String):
	var popup_label = $UI/TreasurePopup
	popup_label.text = "Got %s!" % item_name
	popup_label.visible = true
	popup_label.modulate = Color(1, 1, 1, 1)  # Reset alpha
	popup_label.position = Vector2(get_viewport().size.x / 2, 50)

	var tween = create_tween()
	tween.tween_property(popup_label, "modulate:a", 0.0, 1.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
func _input(event):
	if event.is_action_pressed("toggle_inventory"):  
		toggle_inventory()
	elif event.is_action_pressed("pause"):  
		pause()

func pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_screen.visible = is_paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_HIDDEN)
	
func toggle_inventory():
	inventory_visible = !inventory_visible
	inventory_ui.visible = inventory_visible
	
	if inventory_visible:
		update_inventory_display()
		
	
		
func update_inventory_display():
	for child in item_list_container.get_children():
		child.queue_free()
		
	# Add 'Collected' banner at the top
	var banner = TextureRect.new()
	banner.texture = preload("res://assets/inventory-banner.png")  # Replace with your actual path
	banner.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	banner.custom_minimum_size = Vector2(500, 100)
	banner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_list_container.add_child(banner)

	for item_name in Inventory.items.keys():
		var count = Inventory.get_item_count(item_name)

		# Outer container to hold shelf background + item overlay
		var layered_container = Control.new()
		layered_container.custom_minimum_size = Vector2(0, 100)
		layered_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Shelf background (bottom layer)
		var shelf_bg = TextureRect.new()
		shelf_bg.texture = preload("res://assets/shelf.png")  
		shelf_bg.expand = true
		shelf_bg.stretch_mode = TextureRect.STRETCH_SCALE
		shelf_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		shelf_bg.anchor_right = 1
		shelf_bg.anchor_bottom = 1
		shelf_bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
		shelf_bg.custom_minimum_size = Vector2(500, 100)

		layered_container.add_child(shelf_bg)

		# Item row (top layer)
		var item_row = HBoxContainer.new()
		item_row.anchor_right = 1
		item_row.anchor_bottom = 1
		item_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
		item_row.custom_minimum_size = Vector2(0, 64)

		var icon = TextureRect.new()
		icon.texture = Inventory.item_sprites.get(item_name, null)
		icon.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		icon.custom_minimum_size = Vector2(48, 48)
		if item_name == "Coin":
			icon.scale = Vector2(1.5, 1.5)

		var label = Label.new()
		label.label_settings = label_settings
		label.text = "%s: %d" % [item_name.capitalize(), count]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		item_row.add_child(icon)
		item_row.add_child(label)

		layered_container.add_child(item_row)
		item_list_container.add_child(layered_container)




func update_inventory_count():
	var total = Inventory.get_total_item_count()
	var needed = 15
	count_label.label_settings = label_settings
	count_label.text = "%s out of %d" % [total, needed]
	
func spawn_treasures():
	if treasure_scenes.is_empty():
		push_error("No treasure scenes assigned!")
		return

	var spawn_positions: Array[Vector2] = []

	for i in range(num_treasures):
		var treasure_scene = treasure_scenes.pick_random()
		var treasure_instance = treasure_scene.instantiate()

		var position = get_valid_spawn_position(spawn_positions, 100)
		if position != null:
			treasure_instance.position = position
			treasure_container.add_child(treasure_instance)
			spawn_positions.append(position)

func get_valid_spawn_position(existing_positions, min_distance):
	var max_tries = 30
	var map_bounds = Rect2(Vector2(0, 0), Vector2(2200, 2100))  

	for i in range(max_tries):
		var candidate = Vector2(
			randf_range(map_bounds.position.x, map_bounds.end.x),
			randf_range(map_bounds.position.y, map_bounds.end.y)
		)
		
		var too_close = false
		for pos in existing_positions:
			if candidate.distance_to(pos) < min_distance:
				too_close = true
				break

		if not too_close:
			return candidate

	return null  
