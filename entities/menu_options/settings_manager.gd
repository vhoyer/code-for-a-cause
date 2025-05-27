# class_name SettingsManager
extends Node

signal settings_updated(key: String)

var _storage:= JSONStorage.new('', 'settings')

func _ready() -> void:
	set_language(_storage.get_item('language', 'en'))


func set_language(locale: String) -> void:
	TranslationServer.set_locale(locale)
	_storage.set_item('language', locale)
	settings_updated.emit('language')


func set_screen_shake(new_value: int) -> void:
	_storage.set_item('screen_shake', new_value)
	settings_updated.emit('screen_shake')

func get_screen_shake() -> int:
	return _storage.get_item('screen_shake', 20)


func set_speedrun_timer(value: bool) -> void:
	_storage.set_item('speedrun_timer', value)
	settings_updated.emit('speedrun_timer')

func get_speedrun_timer() -> bool:
	return _storage.get_item('speedrun_timer', false)
