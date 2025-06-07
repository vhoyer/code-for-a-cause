extends VBoxContainer

func _input(event: InputEvent) -> void:
	if not event.is_action('ui_secondary'): return
	var save = get_viewport().gui_get_focus_owner()
	if save is MenuItemSaveButton:
		var save_item = save.get_menu_item_save()
		if save_item._save_data.empty():
			# if no save data, do nothing
			return
		var prompt = tr('Are you sure you want to delete this save file with time {time} recorded?'.format({
			'time': Util.time_display(save_item._save_data.global_time),
		}))
		var yes = await GlobalModal.prompt(prompt)
		if yes: save_item.erase_data()
