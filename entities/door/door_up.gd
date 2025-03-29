@tool
extends StaticBody2D
class_name Door

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var glow_player: AnimationPlayer = $glow_player
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

signal _model_updated()

@export
var is_open: bool = false:
	set(value):
		if is_open == value: return
		is_open = value
		_model_updated.emit()

@export
var power_counter: int = 0:
	set(value):
		glow_player.play('glow')
		power_counter = value
		is_open = power_counter > 0


func _ready() -> void:
	_model_updated.connect(_update_view)


func _update_view() -> void:
	audio_stream_player.play(0.4)
	if is_open:
		animation_player.play("open")
	else:
		animation_player.play_backwards("open")
