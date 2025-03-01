extends Button
class_name ButtonSceneChanger

@export var scene: PackedScene

## If go_back is set to true, scene variable will be ignored
@export var go_back: bool = false
@export var go_back_by: int = 1

@export var payloads: Dictionary

var has_scene_manager: bool:
	get():
		return StageManager.singleton != null

func _ready() -> void:
	connect("button_up", _button_up)

func _button_up() -> void:
	if has_scene_manager:
		var mngr = StageManager.singleton
		if go_back:
			StageManager.go_back(go_back_by)
		else:
			for key in payloads.keys():
				StageManager.set_payload(key, payloads[key])
			mngr.change_stage_to_packed(scene)
	else:
		var err = get_tree().change_scene_to_packed(scene)
		if err != OK: print(error_string(err))
