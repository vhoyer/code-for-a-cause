extends Node2D

func _ready() -> void:
	self.global_position = get_viewport_rect().size / 2
