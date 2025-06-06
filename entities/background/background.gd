@tool
extends Node2D

signal _model_updated()

@export_enum('garden', 'factory')
var type: String = 'factory':
	set(value):
		type = value
		_model_updated.emit()

const MAP:= {
	'garden': "res://entities/background/garden/garden_background.tscn",
	'factory': "res://entities/background/factory/factory_background.tscn",
}

func _ready() -> void:
	_model_updated.connect(update_view)
	update_view()


func update_view() -> void:
	if not MAP.has(type):
		push_error("wtf? what have you done to select an incorrect type? this shouldn't be possible")
	Util.remove_children(self)
	var inst = load(MAP.get(type))
	var bg = inst.instantiate()
	self.add_child(bg)
