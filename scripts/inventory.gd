extends Node

var items: Dictionary = {}

func add_item(item_name: String):
	if items.has(item_name):
		items[item_name] += 1
	else:
		items[item_name] = 1
	print("Added item:", item_name, "| New count:", items[item_name]) 

func get_item_count(item_name: String) -> int:
	return items.get(item_name, 0)
	
func get_total_item_count() -> int:
	var total = 0
	for value in items.values():
		total += value
	return total

func print_inventory():
	for item in items:
		print("%s: %d" % [item, items[item]])
		

func get_all_items() -> Dictionary:
	return items
	
func reset():
	items.clear()
	
@export var item_sprites: Dictionary = {
	"Coin": preload("res://assets/coin-new.png"),
	"GrapeCap": preload("res://assets/grape-cap.png"),
	"OrangeCap": preload("res://assets/orange-cap.png"),
	"OldCan": preload("res://assets/can.png"),
	"RustyKey": preload("res://assets/rusty-key.png"),
	"BentSpoon": preload("res://assets/bent-spoon.png"),
	"BottleOpener": preload("res://assets/bottle-opener.png"),
	"SodaTab": preload("res://assets/soda-tab.png"),
	"FishingHook": preload("res://assets/fishing-hook.png"),
}
