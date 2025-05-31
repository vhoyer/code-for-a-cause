@tool
extends Area2D
class_name JoeInWaiting

signal _model_updated()

@export
var player: PlayerController

@export_enum("brown", "yellow", "violet", "red", "cyan")
var color: String = "brown":
	set(value):
		color = value
		_model_updated.emit()

var activated: bool = false

func _ready() -> void:
	_model_updated.connect(update_view)
	update_view()


func update_view() -> void:
	$Joe.color = color


func add_a_joe() -> void:
	self.queue_free()
	if activated:
		player.add_a_joe($Joe)


func _on_body_entered_exited(body: Node2D) -> void:
	if activated: return

	var body_list = self.get_overlapping_bodies()
	var is_a_joe = body_list.any(func(body: Node2D):
		return body.is_in_group('active_actor'))

	if is_a_joe:
		activated = true
		add_a_joe()
