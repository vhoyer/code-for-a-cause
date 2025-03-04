extends Area2D

signal obj()

func _on_body_entered(body: Node2D) -> void:
	if self.process_mode == PROCESS_MODE_DISABLED: return
	var list = self.get_overlapping_bodies()
	if list.all(func(body): return body is Character) and list.size() == 2:
		obj.emit()
