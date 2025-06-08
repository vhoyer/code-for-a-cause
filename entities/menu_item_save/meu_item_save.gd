@tool
class_name MenuItemSave
extends MarginContainer

signal _model_updated()
signal selected(save_data: SaveData)

@export
var save_index: int = 0:
	set(value):
		save_index = value
		_model_updated.emit()


@onready var layout: MarginContainer = %Layout
@onready var layout_saved: HBoxContainer = %LayoutSaved
@onready var layout_new_game: CenterContainer = %LayoutNewGame

var _save_data: SaveData

var original_top: int
var original_bottom: int

func _ready() -> void:
	if not Engine.is_editor_hint():
		load_data()

	original_top = layout.get_theme_constant("margin_top")
	original_bottom = layout.get_theme_constant("margin_bottom")

	_model_updated.connect(update_view)
	update_view()


func update_view() -> void:
	if not _save_data or _save_data.empty():
		layout_saved.modulate = Color.TRANSPARENT
		layout_new_game.show()
	else:
		layout_saved.modulate = Color.WHITE
		layout_new_game.hide()
		%Timer.text = Util.time_display(_save_data.global_time)
		%Deaths.text = tr('deaths: %d', 'save file display') % [_save_data.deaths]
		if _save_data.level:
			var name = _save_data.level
			if name.begins_with('uid://'):
				name = ResourceUID.get_id_path(ResourceUID.text_to_id(name))
			%Area.text = name.get_basename().get_file().replace('_', ' ')
		else:
			%Area.text = tr('level 1')
		%GameMode.visible = _save_data.new_game_plus > 0
		%GameMode.text = tr('New Game', 'New Game Plus (+ will be added to the end of this string)') + '+'.repeat(_save_data.new_game_plus)


func load_data() -> void:
	_save_data = SaveData.new(save_index)


func erase_data() -> void:
	_save_data.amnesia()
	_model_updated.emit()


func _on_button_button_down() -> void:
	layout.add_theme_constant_override("margin_top", original_bottom)
	layout.add_theme_constant_override("margin_bottom", original_top)
	selected.emit(_save_data)


func _on_button_button_up() -> void:
	layout.add_theme_constant_override("margin_top", original_top)
	layout.add_theme_constant_override("margin_bottom", original_bottom)
