## This Node should be the root node of the main scene project
# class_name StageManager
extends Node


#region Public API
func get_payload(key, default = null):
	var pay = _payloads
	if !pay.has(key): return default
	var value = pay[key]
	pay.erase(key)
	return value

func set_payload(key, value):
	_payloads[key] = value
	payload_updated.emit(key)


func go_back(index: int = 1, payload_append = {}):
	_current_cursor -= index

	var cur_index = _current_cursor
	var cur_history_entry = _history[cur_index]
	_payloads = cur_history_entry.payloads.duplicate(true)
	_payloads.merge(payload_append, true)
	_update_current_stage()

func reload_current_stage(payload_append = {}) -> void:
	go_back(0, payload_append)

func push_stage(scene: String, payload_append = {}) -> void:
	_payloads.merge(payload_append, true)
	_change_stage_to_file(scene)

func go_to_start(payload_append = {}) -> void:
	var hist = _history
	go_back(hist.size() - 1, payload_append)
#endregion


class HistoryEntry:
	var stage_file: String
	var payloads: Dictionary
	func _init(lstage_file, lpayloads):
		self.stage_file = lstage_file
		self.payloads = lpayloads



signal payload_updated(key: Variant)
signal stage_changed
signal _stage_loaded(stage: PackedScene)

var current_stage: Node:
	get():
		return get_tree().current_scene

var _payloads: Dictionary = {}

var _history: Array[HistoryEntry] = []
var _current_cursor: int = 0
var _current_history: HistoryEntry:
	get():
		return _history[_current_cursor]


var _loading: bool = false
var _loading_status: ResourceLoader.ThreadLoadStatus
var _loading_progress: Array = []

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

	var main_stage = ProjectSettings.get_setting(
		'application/run/main_scene',
		get_tree().current_scene.scene_file_path)
	_append_to_history(main_stage)


func _process(_delta: float) -> void:
	if not _loading: return
	_load_step()


func _load_begin() -> PackedScene:
	_loading = true
	ResourceLoader.load_threaded_request(_current_history.stage_file)
	return await _stage_loaded

func _load_step() -> void:
	_loading_status = ResourceLoader.load_threaded_get_status(
		_current_history.stage_file,
		_loading_progress)

	match _loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# nothing to see here, everyone, keep going
			pass
		ResourceLoader.THREAD_LOAD_LOADED:
			_load_done()
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, \
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error('Error: Scene failed to load or is invalid')

func _load_done() -> void:
	var stage: PackedScene = ResourceLoader.load_threaded_get(_current_history.stage_file)

	_loading = false
	_loading_progress = []
	_loading_status = ResourceLoader.THREAD_LOAD_INVALID_RESOURCE

	_stage_loaded.emit(stage)


func _append_to_history(path):
	_history.append(HistoryEntry.new(path, _payloads.duplicate(true)))


func _change_stage_to_file(scene: String) -> void:
	if _current_cursor != _history.size() - 1:
		_history.resize(_current_cursor + 1)

	_append_to_history(scene)
	_current_cursor += 1
	_update_current_stage()


func _update_current_stage() -> void:
	var tree:= get_tree()
	tree.paused = true

	var stage = await _load_begin()

	tree.paused = false
	tree.change_scene_to_packed(stage)
