class_name SaveData
extends RefCounted

var _short_term: InMemoryStorage
var _long_term: JSONStorage

var save_id: String

func _init(index: int) -> void:
	save_id = 'save%s' % index
	_long_term = JSONStorage.new('', save_id)
	_short_term = InMemoryStorage.new('', save_id)
	_short_term._override_with(_long_term)


func consolidate_memory() -> void:
	_long_term._override_with(_short_term)


func remember() -> void:
	_short_term._override_with(_long_term)


func amnesia() -> void:
	_long_term.erase_storage()
	_short_term.erase_storage()


var global_time: float:
	get():
		return _short_term.get_item('global_time', 0)
	set(value):
		_short_term.set_item('global_time', value)

var deaths: int:
	get():
		return _short_term.get_item('deaths', 0)

var unskippable_credits: bool:
	get():
		return _short_term.get_item('unskippable_credits', false)
	set(value):
		_short_term.set_item('unskippable_credits', value)

var level: int:
	get():
		return _short_term.get_item('level', 0)
	set(value):
		_short_term.set_item('level', value)

var new_game_plus: int:
	get():
		return _short_term.get_item('new_game_plus', 0)

var switch_count: int:
	get():
		return _short_term.get_item('switch_count', 0)


func empty() -> bool:
	return global_time == 0


func increment_deaths() -> void:
	_short_term.set_item('deaths', deaths + 1)


func increment_joe_switch() -> void:
	_short_term.set_item('switch_count', switch_count + 1)
	var key = 'switch_count[%s]' % [LevelsManager.current.area]
	_short_term.set_item(key, _short_term.get_item(key, 0))


func increment_new_game_plus() -> void:
	if new_game_plus >= 2:
		# no new game plus version of the game
		return
	_short_term.set_item('new_game_plus', new_game_plus + 1)
	_short_term.set_item('switch_count', 0)
