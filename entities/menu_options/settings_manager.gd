# class_name SettingsManager
extends Node

var _storage:= JSONStorage.new('', 'settings')

func _ready() -> void:
	set_language(_storage.get_item('language', 'en'))


func set_language(locale: String) -> void:
	TranslationServer.set_locale(locale)
	_storage.set_item('language', locale)


func set_screen_shake(new_value: int) -> void:
	_storage.set_item('screen_shake', new_value)

func get_screen_shake() -> int:
	return _storage.get_item('screen_shake', 20)
