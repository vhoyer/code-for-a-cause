@tool
extends Area2D

signal _model_updated

@export var controller_texture: Texture2D:
	set(value):
		controller_texture = value
		_model_updated.emit()

@export var keyboard_texture: Texture2D:
	set(value):
		keyboard_texture = value
		_model_updated.emit()

@onready var input_prompt: InputPrompt = $InputPrompt

var active: bool = false:
	set(value):
		active = value
		_model_updated.emit()

func _ready() -> void:
	_model_updated.connect(update_view)
	update_view()


func update_view() -> void:
	input_prompt.controller_texture = controller_texture
	input_prompt.keyboard_texture = keyboard_texture
	input_prompt.visible = active


func _on_body_entered_exited(body: Node2D) -> void:
	var body_list = self.get_overlapping_bodies()
	active = body_list.any(func(body: Node2D):
		return body is Joe)
