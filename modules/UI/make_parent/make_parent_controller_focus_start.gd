extends Node
class_name MakeParentControllerFocusStart

func _process(_delta: float) -> void:
	if not get_viewport().gui_get_focus_owner():
		if Input.get_connected_joypads().size() > 0:
			self.get_parent().grab_focus()
