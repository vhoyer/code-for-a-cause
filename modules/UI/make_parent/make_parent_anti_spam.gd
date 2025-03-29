extends Node
class_name MakeParentAntiSpam

@export
var cooldown_time: float = 1.5

var parent: Control


func _ready() -> void:
	parent = get_parent()


func _process(_delta: float) -> void:
	var is_visible = parent.is_visible_in_tree()
	if not is_visible and not parent.disabled:
		parent.disabled = true
	elif is_visible and parent.disabled:
		await get_tree().create_timer(cooldown_time).timeout
		parent.disabled = false
