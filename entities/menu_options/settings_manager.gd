# class_name SettingsManager
extends Node

var _storage:= JSONStorage.new('', 'settings')

func _ready() -> void:
	set_language(_storage.get_item('language', 'en'))


func set_language(locale: String) -> void:
	TranslationServer.set_locale(locale)
	_storage.set_item('language', locale)
