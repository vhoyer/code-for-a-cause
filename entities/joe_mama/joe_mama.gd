extends Area2D
class_name JoeMama

signal active_changed(active: bool)

var active: bool = false:
	set(value):
		if active == value: return
		active = value
		active_changed.emit(active)

func _on_body_entered_exited(body: Node2D) -> void:
	var body_list = self.get_overlapping_bodies()
	active = body_list.any(func(body: Node2D):
		return body is Joe)
