extends Button

@onready var options_panel: Panel = %OptionsPanel

func _pressed() -> void:
	options_panel.visible = self.button_pressed
