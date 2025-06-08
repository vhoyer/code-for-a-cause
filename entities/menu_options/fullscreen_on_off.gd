@tool
class_name FullscreenOnOff
extends HWheelPickerButton

func _ready() -> void:
	self.clear_items()
	self.add_item(tr('On', &"true false picker"), DisplayServer.WINDOW_MODE_FULLSCREEN)
	self.add_item(tr('Off', &"true false picker"), DisplayServer.WINDOW_MODE_WINDOWED)
	if Engine.is_editor_hint(): return
	self.selected = self.get_index_by_metadata(SettingsManager.get_fullscreen())


func _on_item_selected(index: int) -> void:
	SettingsManager.set_fullscreen(
		self.get_item_metadata(index))
