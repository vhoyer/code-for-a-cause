class_name CutsceneMamaKidnapped
extends Node2D

signal active_changed(active: bool)

@export
var dialogue: DialogueResource


@onready var positions: Node = %FramePositions
@onready var camera: Camera2D = %Camera2D

func _ready() -> void:
	DialogueManager.show_dialogue_balloon(dialogue)


func go_to(name: String) -> void:
	var marker: Marker2D = positions.get_node(NodePath(name))
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(camera, 'global_position', marker.global_position, 1)
	await tween.finished
