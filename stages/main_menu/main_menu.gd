extends Node2D

@onready var label: Label = %Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not get_viewport().gui_get_focus_owner():
		if Input.get_connected_joypads().size() > 0:
			$CanvasLayer/CenterContainer/PanelContainer/VBoxContainer/ButtonSceneChanger1.grab_focus()

func _ready() -> void:
	label.text = str(StageManager.get_payload('score', 0))
