extends Node2D


func _ready() -> void:
	%BG_Joes


func _stage_out(tween: Tween, fade_to_color: Callable) -> void:
	var width = get_viewport_rect().size.x
	
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


func _on_start_button_pressed() -> void:
	%MainMenu.hide()
	%LoadMenu.show()


func _on_load_menu_back_button_pressed() -> void:
	%LoadMenu.hide()
	%MainMenu.show()


func _on_menu_item_save_selected(save_data: SaveData) -> void:
	SaveManager.load_data(save_data)
	LevelsManager.load_level()
