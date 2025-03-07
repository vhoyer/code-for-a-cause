@tool
extends StaticBody2D

@onready var activation_area: Area2D = $ActivationArea
@onready var sprite_2d: Sprite2D = $Sprite2D

signal active_changed(active: bool)

@export_range(0, 15, 0.5, "or_greater")
var seconds_to_require_reactivation: float = 10.0

var active: bool:
	set(value):
		if active == value: return
		active = value
		active_changed.emit(value)

@export
var weight_to_trigger: int = 4

@export
var weight: int = 0:
	set(value):
		weight = value
		active = (weight >= weight_to_trigger)


func _ready() -> void:
	active_changed.connect(_on_active_changed)


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
