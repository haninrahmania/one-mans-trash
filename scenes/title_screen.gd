extends CanvasLayer


func _ready():
	$PlayButton.pressed.connect(_on_play_pressed)
	$ExitButton.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	$ButtonClick.play()
	await $ButtonClick.finished
	get_tree().change_scene_to_file("res://scenes/BeachLevel.tscn")

func _on_exit_pressed():
	$ButtonClick.play()
	await $ButtonClick.finished
	get_tree().quit()
