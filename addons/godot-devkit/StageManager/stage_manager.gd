## This Node should be the root node of the main scene project
# class_name StageManager
extends Node

const CHILD_SCHENE_NAME = "scene"

static var singleton: StageManager:
	get():
		if !singleton:
			push_error("Error: singleton not loaded")
			return
		return singleton


func get_payload(key, default = null):
	var pay = StageManager.singleton.payloads
	if !pay.has(key): return default
	var value = pay[key]
	pay.erase(key)
	return value

func set_payload(key, value):
	StageManager.singleton.payloads[key] = value
	StageManager.singleton.payload_updated.emit(key)


func go_back(index: int = 1, payload_append = {}):
	StageManager.singleton.current_cursor -= index

	var cur_index = StageManager.singleton.current_cursor
	var cur_history_entry = StageManager.singleton.history[cur_index]
	StageManager.singleton.payloads = cur_history_entry.payloads.duplicate(true)
	StageManager.singleton.payloads.merge(payload_append, true)
	StageManager.singleton._update_current_stage()

func reload_current_stage(payload_append = {}) -> void:
	go_back(0, payload_append)

func push_stage(scene: String, payload_append = {}) -> void:
	StageManager.singleton.payloads.merge(payload_append, true)
	StageManager.singleton._change_stage_to_file(scene)

func go_to_start(payload_append = {}) -> void:
	var hist = StageManager.singleton.history
	go_back(hist.size() - 1, payload_append)


func get_current_stage() -> Node:
	return StageManager.singleton.current_instance

signal payload_updated(key: Variant)
signal stage_changed

var payloads: Dictionary = {}

class HistoryEntry:
	var stage: String
	var payloads: Dictionary
	func _init(lstage, lpayloads):
		self.stage = lstage
		self.payloads = lpayloads

var history: Array[HistoryEntry] = []

func _append_to_history(path):
	history.append(HistoryEntry.new(path, payloads.duplicate(true)))

var current_cursor: int = 0

var current_instance: Node

func _init() -> void:
	singleton = self

func _ready() -> void:
	var main_stage = ProjectSettings.get_setting(
		'application/run/main_scene',
		get_tree().current_scene.scene_file_path)
	_append_to_history(main_stage)


func _change_stage_to_file(scene: String) -> void:
	if current_cursor != history.size() - 1:
		history.resize(current_cursor + 1)

	_append_to_history(scene)
	current_cursor += 1
	_update_current_stage()

func _update_current_stage() -> void:
	var tree:= get_tree()

	#tree.unload_current_scene()

	var scene = history[current_cursor].stage
	tree.change_scene_to_file(scene)

	stage_changed.emit()
