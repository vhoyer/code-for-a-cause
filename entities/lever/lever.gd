extends StaticBody2D

@onready var activation_area: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal active_changed(active: bool)

var listening: bool = false

var active: bool:
	set(value):
		if active == value: return
		active = value
		active_changed.emit(value)

func _ready() -> void:
	active_changed.connect(_on_active_changed)


func _on_active_changed(_active: bool) -> void:
	animation_player.play("switch_on" if active else "switch_off")


func _process(_delta: float) -> void:
	if not listening: return
	if Input.is_action_just_pressed("interact"):
		active = !active


func _on_area_2d_body_entered_or_exited(_body: Node2D) -> void:
	var collision_list = activation_area.get_overlapping_bodies()
	var actors_on_button = collision_list.any(func(body: PhysicsBody2D):
		return body.is_in_group("lever_actor"))

	listening = actors_on_button
