## class_name GlobalBGM
extends AudioStreamPlayer

const TWEEN_DURATION = 0.5
const VOLUME_DELTA = 10

var last_pause_state: bool = false
var tree: SceneTree


func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	tree = get_tree()


func _process(delta: float) -> void:
	if not last_pause_state and tree.paused:
		# just got paused
		volume_tween(-1 * VOLUME_DELTA)
	elif last_pause_state and not tree.paused:
		volume_tween(VOLUME_DELTA)

	last_pause_state = tree.paused


func volume_tween(volume_delta_db: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, 'volume_db', self.volume_db + volume_delta_db, TWEEN_DURATION)


func push_bgm(player: AudioStreamPlayer) -> void:
	if self.stream == player.stream:
		return
	self.stream = player.stream
	self.play()
