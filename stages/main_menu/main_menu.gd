extends Node2D

@onready var button_scene_changer: ButtonSceneChanger = $CanvasLayer/CenterContainer/PanelContainer/VBoxContainer/ButtonSceneChanger
@onready var label: Label = %Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.get_connected_joypads().size() > 0:
		button_scene_changer.grab_focus()

func _ready() -> void:
	label.text = str(StageManager.get_payload('score', 0))
