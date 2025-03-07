extends Node2D

@export
var autoscroll: bool = false

func _ready() -> void:
	self.global_position = get_viewport_rect().size / 2
