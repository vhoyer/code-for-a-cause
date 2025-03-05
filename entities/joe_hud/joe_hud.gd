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

var is_selected: bool = false

func _ready() -> void:
	input_prompt.controller_texture = controller_input
	input_prompt.keyboard_texture = keyboard_input

	progress_bar.max_value = joe.MAX_HEALTH

	player.updated_selected_joe.connect(func(selected_joe):
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

	self.global_position = joe.global_position \
		+ joe.visual_root.position \
		- camera.global_position \
		+ floating_center.position \
		- half_size

	var bubble_size = 40
	var direction_to_center = ((self.global_position + half_size) - floating_center.global_position - joe.visual_root.position)
	var distance = direction_to_center.length()
	var desired_increment = (-1 if (distance > bubble_size * 2) else 1)
	floating_position_increment_factor = move_toward(floating_position_increment_factor, desired_increment, 0.3)
	self.global_position += direction_to_center.normalized() * bubble_size * floating_position_increment_factor


func update_view() -> void:
	self.visible = !!joe
	if not joe: return

	joe.health_updated.connect(func(health):
		match health:
			var x when x <= 0:
				input_prompt.modulate.a = 0
				self.material.set("shader_parameter/mode", 0)
				self.visible = !floating
			var x when x > HEALTH_WARN:
				input_prompt.modulate.a = 0.8
				self.material.set("shader_parameter/mode", 0)
			_:
				self.material.set("shader_parameter/mode", 1)
				input_prompt.modulate.a = 1
		if is_selected:
				input_prompt.modulate.a = 0.2
		progress_bar.value = health)
