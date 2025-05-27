@tool
class_name SpeedrunOnOff
extends HWheelPickerButton

func _ready() -> void:
	self.clear_items()
	self.add_item('On', true)
	self.add_item('Off', false)
	self.selected = self.get_index_by_metadata(SettingsManager.get_speedrun_timer())


func _on_item_selected(index: int) -> void:
	SettingsManager.set_speedrun_timer(
		self.get_item_metadata(index))
