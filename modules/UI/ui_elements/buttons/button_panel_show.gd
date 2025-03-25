extends BaseButton

@export var panel: Control

func _ready() -> void:
	panel.visible = false

func _pressed() -> void:
	panel.show()
