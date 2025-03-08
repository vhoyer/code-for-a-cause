extends Area2D
class_name JoeInWaiting

signal active_changed(active: bool)

var active: bool = false:
	set(value):
		if active == value: return
		active = value
		active_changed.emit(active)


func _ready() -> void:
	active_changed.connect(update_view)


func update_view() -> void:
	self.visible = !active


func _on_body_entered_exited(body: Node2D) -> void:
	var body_list = self.get_overlapping_bodies()
	var is_a_joe = body_list.any(func(body: Node2D):
		return body is Joe)
	if is_a_joe:
		active = true
