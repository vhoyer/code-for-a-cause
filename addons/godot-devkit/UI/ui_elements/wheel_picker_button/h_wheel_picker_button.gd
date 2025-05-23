@tool
@icon("res://addons/godot-devkit/UI/ui_elements/wheel_picker_button/h_wheel_picker_button.svg")
class_name HWheelPickerButton
extends BaseButton

signal _model_updated()
signal item_selected(index: int)

@export
var selected: int = 0:
	set(value):
		selected = value
		_model_updated.emit()
		item_selected.emit(selected)


@export_group('styling')
@export
var label_style_previous: String = '<'
@export
var label_style_next: String = '>'
@export
var focused_label_settings:= LabelSettings.new()


class Item extends RefCounted:
	var text: String
	var metadata: Variant

var _items: Array[Item]:
	get():
		if not _items:
			_items = []
		return _items

func add_item(text: String, metadata: Variant = null) -> int:
	var index = _items.size()

	var new_item = Item.new()
	new_item.text = text
	new_item.metadata = metadata

	_items.push_back(new_item)
	_model_updated.emit()
	return index

func remove_item(index: int) -> void:
	_items.remove_at(index)
	_model_updated.emit()

func clear_items() -> void:
	_items.resize(0)
	_model_updated.emit()

func get_item_metadata(index: int) -> Variant:
	return _items.get(index).metadata

func set_item_metadata(index: int, metadata: Variant) -> void:
	_items.get(index).metadata = metadata
	_model_updated.emit()

func get_item_text(index: int) -> String:
	return _items.get(index).text

func set_item_text(index: int, text: String) -> void:
	_items.get(index).text = text
	_model_updated.emit()


var _layout: HBoxContainer
var _selected_text: Label
var _btn_prev: Button
var _btn_next: Button


func _init() -> void:
	self.pressed.connect(_select_next_item)
	self.ready.connect(func():
		self.focus_entered.connect(_on_focus_entered)
		self.focus_exited.connect(_on_focus_exited)

		item_selected.connect(_item_selected)

		_model_updated.connect(_update_view)
		_update_view())

	_layout = HBoxContainer.new()
	self.add_child(_layout)
	_layout.alignment = BoxContainer.ALIGNMENT_CENTER
	_layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_btn_prev = Button.new()
	_layout.add_child(_btn_prev)
	_btn_prev.text = label_style_previous
	_btn_prev.flat = true
	_btn_prev.theme_type_variation = &"FlatButton"
	_btn_prev.focus_mode = Control.FOCUS_NONE
	_btn_prev.size = Vector2.ZERO
	_btn_prev.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
	_btn_prev.pressed.connect(_select_prev_item)

	_selected_text = Label.new()
	_layout.add_child(_selected_text)
	_selected_text.text = ' '
	_selected_text.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

	_btn_next = _btn_prev.duplicate()
	_layout.add_child(_btn_next)
	_btn_next.text = label_style_next
	_btn_next.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	_btn_next.pressed.connect(_select_next_item)


func _update_view() -> void:
	self.custom_minimum_size = _layout.size
	if selected < _items.size():
		_selected_text.text = get_item_text(selected)
	else:
		_selected_text.text = ' '

func _on_focus_entered():
	_selected_text.label_settings = focused_label_settings

func _on_focus_exited():
	_selected_text.label_settings = null


func _input(event: InputEvent) -> void:
	if not self.has_focus(): return

	if event.is_action_pressed('ui_left'):
		accept_event()
		_select_prev_item()
	elif event.is_action_pressed('ui_right'):
		accept_event()
		_select_next_item()


func _select_next_item() -> void:
	selected = wrapi(selected + 1, 0, _items.size())
	self.grab_focus()

func _select_prev_item() -> void:
	selected = wrapi(selected - 1, 0, _items.size())
	self.grab_focus()


func _item_selected(index: int) -> void:
	pass
