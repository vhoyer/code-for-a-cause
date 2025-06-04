class_name UnlockNewGamePlus
extends Node

func _ready() -> void:
	var parent = self.get_parent()
	if parent.has_signal('active_changed'):
		parent.connect('active_changed', _on_active_changed)

func _on_active_changed(active: bool) -> void:
	if not active: return
	SaveManager.data.complete_levels()
	SaveManager.data.consolidate_memory()
