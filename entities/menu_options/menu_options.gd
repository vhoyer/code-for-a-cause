class_name MenuOptions
extends Panel


func _ready() -> void:
	%ShakeAmount.value = SettingsManager.get_screen_shake()


func _on_shake_amount_value_changed(value: float) -> void:
	SettingsManager.set_screen_shake(value)
