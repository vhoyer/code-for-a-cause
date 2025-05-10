class_name InMemoryStorage
extends BaseStorage

static var _storage: Dictionary = {}
static var _backup: Dictionary = {}

func set_item(key: String, value: Variant) -> void:
	_storage[self._get_key(key)] = value


func get_item(key: String, default_value: Variant) -> Variant:
	return _storage.get(self._get_key(key), default_value)


func save_backup() -> void:
	_backup = _storage.duplicate(true)


func override_with_backup() -> void:
	_storage = _backup.duplicate(true)
