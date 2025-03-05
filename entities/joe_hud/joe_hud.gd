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

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var input_prompt: InputPrompt = %InputPrompt

var is_selected: bool = false

func _ready() -> void:
	input_prompt.controller_texture = controller_input
	input_prompt.keyboard_texture = keyboard_input

	progress_bar.max_value = joe.MAX_HEALTH

	player.updated_selected_joe.connect(func(selected_joe):
		is_selected = selected_joe == joe
		self.theme_type_variation = &"SelectedPanelContainer" \
			if is_selected \
			else &"")

	_joe_updated.connect(update_view)
	update_view()


func update_view() -> void:
	self.visible = !!joe
	if not joe: return

	joe.health_updated.connect(func(health):
		match health:
			var x when x <= 0:
				input_prompt.modulate.a = 0
				self.material.set("shader_parameter/mode", 0)
			var x when x > HEALTH_WARN:
				input_prompt.modulate.a = 0.8
				self.material.set("shader_parameter/mode", 0)
			_:
				self.material.set("shader_parameter/mode", 1)
				input_prompt.modulate.a = 1
		if is_selected:
				input_prompt.modulate.a = 0.2
		progress_bar.value = health)
