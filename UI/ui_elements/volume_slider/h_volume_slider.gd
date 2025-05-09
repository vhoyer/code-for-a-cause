@tool
extends HSlider
class_name HVolumeSlider

@export
var bus: StringName:
	set(value):
		bus = value
		_internal_update.emit()


var bus_id

signal _internal_update()


func _ready() -> void:
	self.custom_minimum_size.x = 150.0
	bus_id = AudioServer.get_bus_index(bus)

	self.max_value = 1.0
	self.step = 0.05
	self.value = db_to_linear(AudioServer.get_bus_volume_db(bus_id))
	self.value_changed.connect(_on_h_slider_value_changed)

	_internal_update.emit()

func _on_h_slider_value_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(val))
