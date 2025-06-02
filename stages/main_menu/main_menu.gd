extends Node2D


func _stage_out(tween: Tween, fade_to_color: Callable) -> void:
	var proj_size = Vector2(
		ProjectSettings.get_setting('display/window/size/viewport_width'),
		ProjectSettings.get_setting('display/window/size/viewport_height'))
	var cur_size = DisplayServer.window_get_size()
	var width = proj_size.x / proj_size.aspect() * cur_size.aspect()
	
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func():
		%BG.process_mode = Node.PROCESS_MODE_ALWAYS
		%ChooseLevelPanel.hide()
		for child in %BG.get_children():
			if child is Parallax2D:
				child.autoscroll *= -2)
	tween.tween_property(%BG_Joes, 'position', Vector2(width, 0), 2)
	fade_to_color.call(Color.BLACK, 0.3)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
