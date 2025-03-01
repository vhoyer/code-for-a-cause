extends Node
class_name StageManager
## This Node should be the root node of the main scene project

const CHILD_SCHENE_NAME = "scene"

@export var main_stage: PackedScene

static var singleton: StageManager:
	get():
		if !singleton:
			assert(false, "Error: singleton not loaded")
			return
		return singleton


static func get_payload(key, default = null):
	var pay = StageManager.singleton.payloads
	if !pay.has(key): return default
	var value = pay[key]
	pay.erase(key)
	return value

static func set_payload(key, value):
	StageManager.singleton.payloads[key] = value
	StageManager.singleton.payload_updated.emit(key)


static func go_back(index: int = 1, payload_append = {}):
	StageManager.singleton.current_cursor -= index

	var cur_index = StageManager.singleton.current_cursor
	var cur_history_entry = StageManager.singleton.history[cur_index]
	StageManager.singleton.payloads = cur_history_entry.payloads.duplicate(true)
	StageManager.singleton.payloads.merge(payload_append, true)
	StageManager.singleton.update_current_stage()

static func reload_current_stage(payload_append = {}) -> void:
	go_back(0, payload_append)

static func push_stage(scene: PackedScene, payload_append = {}) -> void:
	StageManager.singleton.payloads.merge(payload_append, true)
	StageManager.singleton.change_stage_to_packed(scene)

static func go_to_start(payload_append = {}) -> void:
	var hist = StageManager.singleton.history
	go_back(hist.size() - 1, payload_append)


static func get_current_stage() -> Node:
	return StageManager.singleton.current_instance

signal payload_updated(key: Variant)
signal stage_changed

var payloads: Dictionary = {}

class HistoryEntry:
	var stage: PackedScene
	var payloads: Dictionary
	func _init(lstage, lpayloads):
		self.stage = lstage
		self.payloads = lpayloads

var history: Array[HistoryEntry] = []

func append_to_history(packed_scene: PackedScene):
	history.append(HistoryEntry.new(packed_scene, payloads.duplicate(true)))

var last_stage: PackedScene:
	get():
		return history.back().stage

var current_cursor: int = 0

var current_instance: Node

func _init() -> void:
	singleton = self

func _ready() -> void:
	append_to_history(main_stage)
	current_instance = main_stage.instantiate()
	current_instance.name = CHILD_SCHENE_NAME
	self.add_child(current_instance)


func change_stage_to_packed(scene: PackedScene) -> void:
	if current_cursor != history.size() - 1:
		history.resize(current_cursor + 1)

	append_to_history(scene)
	current_cursor += 1
	update_current_stage()

func update_current_stage() -> void:
	var scene = history[current_cursor].stage
	self.remove_child(self.find_child(CHILD_SCHENE_NAME+"*", false, false))
	current_instance = scene.instantiate()
	current_instance.name = CHILD_SCHENE_NAME
	self.add_child(current_instance)
	stage_changed.emit()
