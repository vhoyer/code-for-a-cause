class_name CutsceneMamaKidnapped
extends Node2D

signal active_changed(active: bool)

@export
var dialogue: DialogueResource

@export_file("*.tscn", "*.scn")
var next_level_path: String


@onready var positions: Node = %FramePositions
@onready var camera: Camera2D = %Camera2D

func _ready() -> void:
	DialogueManager.show_dialogue_balloon(dialogue)


func next_frame(index:= 0) -> void:
	var marker: Marker2D = positions.get_child(index)
	var tween = create_tween()
	tween.tween_property(camera, 'global_position', marker.global_position, 1)
	await tween.finished


func next_level() -> void:
	StageManager.push_stage(next_level_path)
