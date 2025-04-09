extends Camera2D


func _process(delta):
	var target = get_viewport().get_mouse_position()
	global_position = global_position.lerp(target, 5 * delta)
