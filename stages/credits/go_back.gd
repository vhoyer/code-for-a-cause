extends Node

func _on_credit_roll_credits_end() -> void:
	StageManager.go_back()
