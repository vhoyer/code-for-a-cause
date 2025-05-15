class_name StageChangerBaseButton
extends BaseButton

## If go_back is set to true, scene variable will be ignored
@export_enum('to scene', 'back by count', 'back to start')
var method: String = 'to scene'

@export var payloads: Dictionary

@export_group('count method')
@export
var go_back_by_count: int = 1

@export_group('scene method')
@export_file("*.tscn", "*.scn")
var scene_file: String


var has_scene_manager: bool:
	get():
		return StageManager.singleton != null


func _pressed() -> void:
	if not has_scene_manager:
		var err = get_tree().change_scene_to_file(scene_file)
		if err != OK: print(error_string(err))
		return

	get_tree().paused = false

	match method:
		'to scene':
			for key in payloads.keys():
				StageManager.set_payload(key, payloads[key])
			StageManager.push_stage(scene_file)
		'back to start':
			StageManager.go_to_start()
		'back by count':
			StageManager.go_back(go_back_by_count)
