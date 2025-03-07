extends StaticBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var activation_area: Area2D = $ActivationArea

signal active_changed(active: bool)

@export_range(0, 15, 0.5, "or_greater")
var seconds_to_require_reactivation: float = 10.0

var tween: Tween

var active: bool:
	set(value):
		if active == value: return
		active = value
		active_changed.emit(value)


func _ready() -> void:
	active_changed.connect(_on_active_changed)


func _on_active_changed(_active: bool) -> void:
	animation_player.speed_scale = 1
	if active:
		animation_player.play("down")
	else:
		animation_player.play("up")


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
