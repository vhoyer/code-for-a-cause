@tool
extends VBoxContainer
class_name HVolumeSlider

@export
var bus: StringName:
	set(value):
		bus = value
		_internal_update.emit()


var bus_id
var label: Label
var h_slider: HSlider


signal _internal_update()


func _ready() -> void:
	self.custom_minimum_size.x = 150.0
	bus_id = AudioServer.get_bus_index(bus)

	for child in self.get_children():
		self.remove_child(child)

	label = Label.new()
	self.add_child(label)
	_internal_update.connect(func():
		label.text = bus)

	h_slider = HSlider.new()
	self.add_child(h_slider)
	h_slider.max_value = 1.0
	h_slider.step = 0.05
	h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_id))
	h_slider.value_changed.connect(_on_h_slider_value_changed)

	_internal_update.emit()

func _on_h_slider_value_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(val))
