@tool
extends StaticBody2D

@onready var activation_area: Area2D = $ActivationArea
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = %Label

signal active_changed(active: bool)
signal _model_changed()

@export_range(0, 15, 0.5, "or_greater")
var seconds_to_require_reactivation: float = 10.0

var active: bool:
	set(value):
		if active == value: return
		active = value
		active_changed.emit(value)

@export_range(1, 4, 1)
var weight_to_trigger: int = 4:
	set(value):
		weight_to_trigger = value
		_model_changed.emit()

var weight: int = 0:
	set(value):
		weight = value
		active = (weight >= weight_to_trigger)
		_model_changed.emit()


func _ready() -> void:
	active_changed.connect(_on_active_changed)
	_model_changed.connect(update_view)
	update_view()


func update_view() -> void:
	label.text = str(weight_to_trigger - weight)


func _on_active_changed(_active: bool) -> void:
	if active:
		sprite_2d.frame += 1
	else:
		sprite_2d.frame -= 1


func _on_reactivation_required() -> void:
	active = false


func _on_activation_area_body_entered_or_exited(_body: Node2D) -> void:
	var body_list = activation_area.get_overlapping_bodies()
	var local_weight:= 0
	for body in body_list:
		if body.is_in_group('button_actor'):
			local_weight += 1
	weight = local_weight
