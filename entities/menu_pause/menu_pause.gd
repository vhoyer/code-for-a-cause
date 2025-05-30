extends CanvasLayer

@export
var player: PlayerController
var has_pause_ownership: bool = false

func _ready() -> void:
	self.hide()

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed('pause'): return
	if player and not player.alive: return
	var tree = get_tree()
	if tree.paused and not has_pause_ownership: return
	self.visible = !self.visible
	tree.paused = self.visible
	has_pause_ownership = true


func _on_resume_button_down() -> void:
	self.visible = false
	get_tree().paused = false
	has_pause_ownership = false


func _on_restart_button_down() -> void:
	get_tree().paused = false
	has_pause_ownership = false
	StageManager.reload_current_stage()
