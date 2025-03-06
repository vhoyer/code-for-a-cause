extends Button

@onready var options_panel: PanelContainer = %OptionsPanel

func _pressed() -> void:
	options_panel.visible = self.button_pressed
