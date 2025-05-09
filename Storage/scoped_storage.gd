extends Resource
class_name ScopedStorage

const PATH = 'user://%s_storage.tres'
const PATH_BACKUP = 'user://%s_storage_bkp.tres'

var prefix: String = ''

@export var _scope: String
@export var _storage: Dictionary = {}
static var is_cache_valid = {}


func _init(scope: String = 'global', prefix: String = '') -> void:
	self._scope = scope
	self.is_cache_valid[scope] = true
	var path = _get_path()

	if prefix != '':
		self.prefix = prefix + '::'

	if FileAccess.file_exists(path):
		var loaded = ResourceLoader.load(path, "ScopedStorage")
		self._storage = loaded._storage

func _get_path() -> String:
	return PATH % self._scope

func _get_path_backup() -> String:
	return PATH_BACKUP % self._scope


func set_item(key: String, value: Variant) -> void:
	reload_storage_if_necessary()
	_storage[StringName(prefix + key)] = value
	ResourceSaver.save(self, _get_path())
	is_cache_valid[_scope] = false


func get_item(key: String, default_value: Variant) -> Variant:
	reload_storage_if_necessary()
	return _storage.get(StringName(prefix + key), default_value)


func reload_storage_if_necessary() -> void:
	if is_cache_valid.get(_scope, false):
		# not necessary, cache is valid
		return
	var loaded = ResourceLoader.load(_get_path(), "ScopedStorage", ResourceLoader.CACHE_MODE_IGNORE)
	_storage = loaded._storage
	is_cache_valid[_scope] = true


func save_backup() -> void:
	ResourceSaver.save(self, _get_path_backup())

func override_with_backup() -> void:
	var loaded = ResourceLoader.load(_get_path_backup(), "ScopedStorage", ResourceLoader.CACHE_MODE_IGNORE)
	ResourceSaver.save(loaded, _get_path())
