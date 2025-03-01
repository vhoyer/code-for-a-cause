extends Resource
class_name ScopedStorage

const PATH = 'user://%s_storage.tres'

@export var _scope: String
@export var _storage: Dictionary = {}
static var is_cache_valid = {}


func _init(scope: String = 'global') -> void:
	self._scope = scope
	self.is_cache_valid[scope] = true
	var path = _get_path()

	if FileAccess.file_exists(path):
		var loaded = ResourceLoader.load(path)
		self._storage = loaded._storage

func _get_path() -> String:
	return PATH % self._scope


func set_item(key: StringName, value: Variant) -> void:
	if _storage.get(key) == value:
		# if there is nothing to updated, don't waste resources doing so
		return
	_storage[key] = value
	ResourceSaver.save(self, _get_path())
	is_cache_valid[_scope] = false

func get_item(key: StringName, default_value: Variant) -> Variant:
	if not is_cache_valid.get(_scope, false):
		var loaded = ResourceLoader.load(_get_path(), "ScopedStorage", ResourceLoader.CACHE_MODE_IGNORE)
		_storage = loaded._storage
		is_cache_valid[_scope] = true

	return _storage.get(key, default_value)
