extends Control

@onready var items_container = $Panel/VBoxContainer  

func _ready():
	pass  

func clear_items():
	for child in items_container.get_children():
		child.queue_free()
