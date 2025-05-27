class_name SpeedrunTimer
extends MarginContainer

var _storage:= InMemoryStorage.new('speedrun')

@onready var stopwatch_global: Stopwatch = %StopwatchGlobal
@onready var stopwatch_local: Stopwatch = %StopwatchLocal

func _ready() -> void:
	_on_settings_updated('speedrun_timer')
	stopwatch_global.stopwatch = _storage.get_item('global', 0)
	stopwatch_global.stopwatch_enabled = true

	SettingsManager.settings_updated.connect(_on_settings_updated)


func _on_settings_updated(key: String) -> void:
	if key != 'speedrun_timer':
		return
	self.visible = SettingsManager.get_speedrun_timer()


func _process(_delta: float) -> void:
	_storage.set_item('global', stopwatch_global.stopwatch)
