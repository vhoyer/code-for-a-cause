extends PanelContainer
class_name JoeHud

signal _joe_updated()

const HEALTH_WARN = Joe.MAX_HEALTH / 4


@export var player: PlayerController
@export var joe: Joe:
	set(value):
		joe = value
		_joe_updated.emit()

@export var controller_input: Texture2D
@export var keyboard_input: Texture2D

@export var floating: bool = false
@export var floating_center: Control
var floating_position_increment_factor: float = 0

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var input_prompt: InputPrompt = %InputPrompt
@onready var beeping: AudioStreamPlayer = $Beeping2

var is_selected: bool = false

func _ready() -> void:
	input_prompt.controller_texture = controller_input
	input_prompt.keyboard_texture = keyboard_input

	progress_bar.max_value = joe.MAX_HEALTH

	player.updated_selected_joe.connect(func _on_selected_joe_changed(selected_joe):
		is_selected = selected_joe == joe
		if floating:
			self.modulate.a = 0 if is_selected else 1
		self.theme_type_variation = &"SelectedPanelContainer" \
			if is_selected \
			else &"")

	_joe_updated.connect(update_view)
	update_view()


func _process(_delta: float) -> void:
	if not floating: return
	if not joe: return
	assert(floating_center, 'Error: floating_center needs to be provided')

	var camera = CameraMain.singleton
	var half_size = size / 2

	# position floating hud on top of joe
	self.global_position = joe.global_position \
		+ joe.visual_root.position \
		- camera.global_position \
		+ floating_center.position \
		- half_size

	# make floating hud orbit joe while being pulled towards the center
	var bubble_size = 40
	var direction_to_center = ((self.global_position + half_size) - floating_center.global_position - joe.visual_root.position)
	var distance = direction_to_center.length()
	# instead of pulling to the center, pull away if selected joe and this hud are too close
	var desired_increment = (-1 if (distance > bubble_size * 2) else 1)
	floating_position_increment_factor = move_toward(floating_position_increment_factor, desired_increment, 0.3)
	self.global_position += direction_to_center.normalized() * bubble_size * floating_position_increment_factor

	# limit floating hud to never go outside the screen
	var screen_limit = get_viewport_rect()
	screen_limit.position -= floating_center.position
	screen_limit.size = (screen_limit.size / 2) - self.size
	screen_limit = screen_limit.grow(-25)
	self.position.x = clamp(self.position.x, screen_limit.position.x, screen_limit.size.x)
	self.position.y = clamp(self.position.y, screen_limit.position.y, screen_limit.size.y)


func update_view() -> void:
	self.visible = !!joe
	if not joe: return

	if not joe.health_updated.is_connected(_on_health_updated):
		joe.health_updated.connect(_on_health_updated)


func _on_health_updated(health):
	var length = beeping.stream.get_length()
	var health_warn = min(HEALTH_WARN, length)

	match health:
		var x when x <= 0:
			input_prompt.modulate.a = 0
			self.material.set("shader_parameter/mode", 0)
			beeping.stop()
			self.visible = !floating
		var x when x > health_warn:
			input_prompt.modulate.a = 0.8
			self.material.set("shader_parameter/mode", 0)
			beeping.stop()
		_:
			self.material.set("shader_parameter/mode", 1)
			input_prompt.modulate.a = 1
			if not beeping.playing and floating:
				beeping.play(length - health_warn)
	if is_selected:
			input_prompt.modulate.a = 0.2
	progress_bar.value = health
