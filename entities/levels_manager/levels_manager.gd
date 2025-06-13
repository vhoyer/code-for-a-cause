#class_name LevelsManager
extends Node

const CREDITS_PATH:= "uid://cod16iwe4mb0c"

@export
var levels: Array[GameLevel] = []


var current_index: int = 0:
	get():
		return SaveManager.data.level
	set(value):
		SaveManager.data.level = wrapi(value, -1, levels.size())
		SaveManager.data.consolidate_memory()


var current: GameLevel:
	get():
		return levels[current_index]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('cheat_next_level'):
		next_level()


func get_level(index: int) -> GameLevel:
	if index == -1:
		return levels.front()
	return levels.get(index)


func load_level() -> void:
	if current_index == -1:
		# reached the end of the levels
		SaveManager.data.level = 0
		SaveManager.data.increment_new_game_plus()
		SaveManager.data.consolidate_memory()
		StageManager.push_stage(CREDITS_PATH)
	else:
		StageManager.push_stage(current.scene)


func next_level() -> void:
	current_index += 1
	load_level()
