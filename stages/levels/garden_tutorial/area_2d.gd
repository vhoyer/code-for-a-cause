extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('active_actor'):
		LevelsManager.next_level()
