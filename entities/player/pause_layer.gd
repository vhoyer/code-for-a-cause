extends CanvasLayer

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed('pause'): return
	self.visible = !self.visible
	var tree = get_tree()
	tree.paused = !tree.paused


func _on_resume_button_down() -> void:
	self.visible = false
	get_tree().paused = false
