@tool
extends StaticBody2D
class_name Door

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal _model_updated()

@export
var is_open: bool = false:
	set(value):
		is_open = value
		_model_updated.emit()


func _ready() -> void:
	_model_updated.connect(_update_view)


func _update_view() -> void:
	if is_open:
		animation_player.play("open")
	else:
		animation_player.play_backwards("open")
