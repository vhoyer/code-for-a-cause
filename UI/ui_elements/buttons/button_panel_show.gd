extends BaseButton

@export var panel: Control

func _ready() -> void:
	panel.hide()

func _pressed() -> void:
	panel.show()
