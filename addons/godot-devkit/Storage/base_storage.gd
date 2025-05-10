class_name BaseStorage
extends RefCounted

var prefix: String = ''

func _init(prefix: String = '') -> void:
	if prefix != '':
		self.prefix = prefix + '::'

func _get_key(key: String) -> StringName:
	return StringName(prefix + key)


func get_item(key: String, default_value: Variant) -> Variant:
	push_error('get_item needs to be overwritten')
	return default_value


func set_item(key: String, value: Variant) -> void:
	push_error('set_item needs to be overwritten')


func save_backup() -> void:
	push_error('save_backup needs to be overwritten')


func override_with_backup() -> void:
	push_error('override_with_backup needs to be overwritten')
