extends Control


func _ready():
	$VBoxContainer/HBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer/HBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)
	
	
func _on_resume_pressed():
	$ButtonClick.play()
	await $ButtonClick.finished
	get_tree().paused = false
	get_parent().get_node("PauseScreen").visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_exit_pressed():
	$ButtonClick.play()
	await $ButtonClick.finished
	get_tree().quit()
