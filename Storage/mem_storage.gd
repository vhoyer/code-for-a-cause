extends Resource
class_name MemStorage

var prefix: String = ''

@export var _scope: String
static var _storage: Dictionary = {}


func _init(prefix: String = '') -> void:
	if prefix != '':
		self.prefix = prefix + '::'


func set_item(key: String, value: Variant) -> void:
	_storage[StringName(prefix + key)] = value


func get_item(key: String, default_value: Variant) -> Variant:
	return _storage.get(StringName(prefix + key), default_value)
