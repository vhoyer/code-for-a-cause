extends Node

@export var door: Door

func _ready() -> void:
	var parent = self.get_parent()
	if parent.has_signal('active_changed'):
		parent.connect('active_changed', _on_active_changed)


func _on_active_changed(active: bool) -> void:
	CameraMain.singleton.momentarily_add_to_focus(door.global_position + Vector2(0, 50))
	await get_tree().create_timer(0.5).timeout

	door.power_counter += int(active)
