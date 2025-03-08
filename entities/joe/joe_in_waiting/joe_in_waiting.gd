extends Area2D
class_name JoeInWaiting

@export
var player: PlayerController

var activated: bool = false

func add_a_joe() -> void:
	self.visible = !activated
	if activated:
		player.add_a_joe()


func _on_body_entered_exited(body: Node2D) -> void:
	if activated: return

	var body_list = self.get_overlapping_bodies()
	var is_a_joe = body_list.any(func(body: Node2D):
		return body is Joe)

	if is_a_joe:
		activated = true
		add_a_joe()
