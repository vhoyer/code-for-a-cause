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
var _loading_tween: Tween

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

	var main_stage = ProjectSettings.get_setting(
		'application/run/main_scene',
		get_tree().current_scene.scene_file_path)
	_append_to_history(main_stage)

	setup_transition_layer()


func _process(_delta: float) -> void:
	if not _loading: return
	_load_step()


func _load_begin() -> PackedScene:
	_loading = true
	ResourceLoader.load_threaded_request(_current_history.stage_file)

	var tween = tween_stage_out()
	var stage = await _stage_loaded

	if tween.is_running():
		await tween.finished

	return stage

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
	if _loading:
		push_error("Stage Manager: Can't request change on stage while another change is already in progress")
		return

	if _current_cursor != _history.size() - 1:
		_history.resize(_current_cursor + 1)

	_append_to_history(scene)
	_current_cursor += 1
	_update_current_stage()


func _update_current_stage() -> void:
	var tree:= get_tree()
	tree.paused = true

	var stage = await _load_begin()
	
	tree.change_scene_to_packed(stage)
	await tree.tree_changed

	await tween_stage_in().finished

	tree.paused = false



const TRANSITION_DURATION: float = 0.3
var transition_canvas_layer: CanvasLayer
var transition_color_rect: ColorRect

func setup_transition_layer() -> void:
	transition_canvas_layer = CanvasLayer.new()
	transition_canvas_layer.name = 'CanvasLayerTransition'
	self.add_child(transition_canvas_layer)
	transition_canvas_layer.layer = 128
	transition_canvas_layer.hide()

	transition_color_rect = ColorRect.new()
	transition_canvas_layer.add_child(transition_color_rect)
	transition_color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_color_rect.modulate = Color.TRANSPARENT
	transition_color_rect.color = Color.BLACK

func tween_stage_out() -> Tween:
	_loading_tween = create_tween()
	if current_stage.has_method('_stage_out'):
		current_stage._stage_out(_loading_tween, fade_out_to)
	else:
		fade_out_to(Color.BLACK, TRANSITION_DURATION)

	return _loading_tween

func tween_stage_in() -> Tween:
	_loading_tween = create_tween()
	if current_stage.has_method('_stage_in'):
		current_stage._stage_in(_loading_tween)
	else:
		transition_color_rect.modulate = Color.WHITE
		transition_canvas_layer.show()
		_loading_tween.tween_property(transition_color_rect, 'modulate:a', 0, TRANSITION_DURATION)
		_loading_tween.tween_callback(transition_canvas_layer.hide)

	return _loading_tween

func fade_out_to(color: Color, duration: float) -> void:
	transition_color_rect.color = color
	transition_color_rect.modulate = Color.TRANSPARENT
	transition_canvas_layer.show()
	_loading_tween.tween_property(transition_color_rect, 'modulate:a', 1.0, duration)
