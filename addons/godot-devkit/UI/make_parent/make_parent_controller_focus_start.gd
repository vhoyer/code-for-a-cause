extends Node
class_name MakeParentControllerFocusStart

func _process(_delta: float) -> void:
	var focused_control = get_viewport().gui_get_focus_owner()
	if not focused_control:
		if Input.get_connected_joypads().size() > 0:
			self.get_parent().grab_focus()
