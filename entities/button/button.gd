@tool
extends StaticBody2D

@onready var activation_area: Area2D = $ActivationArea
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var down: AudioStreamPlayer = $down
@onready var up: AudioStreamPlayer = $up

signal _model_updated()
signal active_changed(active: bool)

@export_enum("red", "brown", "yellow", "violet", "cyan")
var color: int = 0:
	set(value):
		color = value
		_model_updated.emit()

@export_range(0, 15, 0.5, "or_greater")
var seconds_to_require_reactivation: float = 10.0

var active: bool:
	set(value):
		if active == value: return
		active = value
		active_changed.emit(value)


func _ready() -> void:
	active_changed.connect(_on_active_changed)
	_model_updated.connect(update_view)


func update_view() -> void:
	sprite_2d.frame_coords.x = color * 2 + int(active)


func _on_active_changed(_active: bool) -> void:
	if active:
		sprite_2d.frame += 1
		down.play()
	else:
		sprite_2d.frame -= 1
		up.play()


func _on_reactivation_required() -> void:
	active = false


func _on_activation_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("button_actor"):
		active = true


func _on_activation_area_body_exited(body: Node2D) -> void:
	var collision_list = activation_area.get_overlapping_bodies()
	var actors_on_button = collision_list.any(func(body: PhysicsBody2D):
		return body.is_in_group("button_actor"))

	if not actors_on_button:
		active = false
