#class_name GlobalModal
extends CanvasLayer

signal response(yes: bool)

@onready var label: RichTextLabel = %Label
@onready var button_confirm: Button = %ButtonConfirm
@onready var button_cancel: Button = %ButtonCancel


func _init() -> void:
	self.hide()


func prompt(
	label_text: String,
	yes_text:= tr('ok', 'prompt dialog default positive button'),
	no_text:= tr('cancel', 'prompt dialog default negative button'),
) -> bool:
	label.text = label_text
	button_confirm.text = yes_text
	button_cancel.text = no_text
	self.show()
	var yes = await response
	self.hide()
	return yes


func _on_button_confirm_pressed() -> void:
	response.emit(true)

func _on_button_cancel_pressed() -> void:
	response.emit(false)
