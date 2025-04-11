extends Control

@onready var item_list_container = $ScrollContainer/ItemListContainer
var label_settings = preload("res://new_label_settings.tres")

func _ready():
	update_win_display()
	$PlayAgainButton.pressed.connect(_on_playAgain_pressed)
	$ExitButton.pressed.connect(_on_exit_pressed)

func update_win_display():
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
		#var item_row = HBoxContainer.new()
#
		## Icon
		#var icon = TextureRect.new()
		#icon.texture = Inventory.item_sprites.get(item_name, null)
		#icon.custom_minimum_size = Vector2(32, 32)
#
		## Label
		#var label = Label.new()
		#label.text = "%s: %d" % [item_name.capitalize(), count]
#
		#item_row.add_child(icon)
		#item_row.add_child(label)
		#item_list_container.add_child(item_row)
		
	# Outer container to hold shelf background + item overlay
		var layered_container = Control.new()
		layered_container.custom_minimum_size = Vector2(0, 100)
		layered_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Shelf background (bottom layer)
		var shelf_bg = TextureRect.new()
		shelf_bg.texture = preload("res://assets/shelf.png")  # replace with your actual path
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

func _on_playAgain_pressed():
	$ButtonClick.play()
	await $ButtonClick.finished
	get_tree().change_scene_to_file("res://scenes/BeachLevel.tscn")

func _on_exit_pressed():
	$ButtonClick.play()
	await $ButtonClick.finished
	get_tree().quit()
	
