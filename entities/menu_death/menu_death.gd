extends CanvasLayer

func _ready() -> void:
	self.hide()

func display() -> void:
	get_tree().paused = true
	self.show()
