extends Node
class_name LevelUtilsGoToNext

@export var next_level: PackedScene
@export var player: PlayerController

func _ready() -> void:
	var parent = self.get_parent()
	if parent.has_signal('active_changed'):
		parent.connect('active_changed', _on_active_changed)

func _on_active_changed(active: bool) -> void: 
	if not active: return

	var between_jump_interval = 0.5
	var tween = create_tween()
	tween.tween_callback(func():
		for joe: Joe in player.joes.get_children():
			joe.control_lock(true)
			joe.velocity.y -= 200)
	tween.tween_interval(between_jump_interval)
	for _i in 4:
		tween.tween_callback(func():
			var list = player.joes.get_children()
			list.shuffle()
			for joe: Joe in list.slice(0, ceil(list.size()/2.0)):
				joe.velocity.y -= 200)
		tween.tween_interval(between_jump_interval)
	tween.tween_callback(func():
		StageManager.push_stage(next_level))
