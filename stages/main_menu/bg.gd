extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().root.size_changed.connect(update_pos)
	update_pos()

func update_pos() -> void:
	self.position.y = get_viewport_rect().size.y / 2
