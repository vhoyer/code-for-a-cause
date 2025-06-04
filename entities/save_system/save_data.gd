class_name SaveData
extends RefCounted

var _short_term: InMemoryStorage
var _long_term: JSONStorage

func _init(index: int) -> void:
	var save_id = 'save%s' % index
	_long_term = JSONStorage.new('', save_id)
	_short_term = InMemoryStorage.new('', save_id)
	_short_term._override_with(_long_term)


func consolidate_memory() -> void:
	_long_term._override_with(_short_term)


func remember() -> void:
	_short_term._override_with(_long_term)



var global_time: float:
	get():
		return _short_term.get_item('global_time', 0)
	set(value):
		_short_term.set_item('global_time', value)

var deaths: int:
	get():
		return _short_term.get_item('deaths', 0)

var level: String:
	get():
		return _short_term.get_item('level', '')
	set(value):
		_short_term.set_item('level', value)


func empty() -> bool:
	return global_time == 0


func increment_deaths() -> void:
	_short_term.set_item('deaths', deaths + 1)
