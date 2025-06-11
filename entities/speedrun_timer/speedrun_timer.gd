class_name SpeedrunTimer
extends MarginContainer

@onready var stopwatch_global: Stopwatch = %StopwatchGlobal

func _ready() -> void:
	_on_settings_updated('speedrun_timer')
	stopwatch_global.stopwatch = SaveManager.data.global_time
	stopwatch_global.stopwatch_enabled = true

	SettingsManager.settings_updated.connect(_on_settings_updated)


func _on_settings_updated(key: String) -> void:
	if key != 'speedrun_timer':
		return
	self.visible = SettingsManager.get_speedrun_timer()


func _process(_delta: float) -> void:
	SaveManager.data.global_time = stopwatch_global.stopwatch
