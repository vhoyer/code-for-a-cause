extends Node
class_name MakeParentControllerFocusStart

var parent: Control
var has_joypad: bool = false

var was_visible = true
var old_focused: Control

func _ready() -> void:
	parent = self.get_parent()

func _process(_delta: float) -> void:
	var focused_control = get_viewport().gui_get_focus_owner()
	var is_visible = parent.is_visible_in_tree()

	has_joypad = Input.get_connected_joypads().size() > 0
	if has_joypad:
		if not focused_control:
			parent.grab_focus()

		if not was_visible and is_visible:
			old_focused = focused_control
			parent.grab_focus()
		elif was_visible and not is_visible and old_focused:
			old_focused.grab_focus()

	was_visible = is_visible
