@tool
extends Node2D
class_name PlayerController

const TUTORIAL_LAYER = 4

signal _model_updated()
signal _player_died()
signal joe_exploded()

@onready var joes: Node2D = $Joes
@onready var joe_hud_holder: HBoxContainer = $CanvasLayer/JoeHudHolder
@onready var joe_hud_floating_holder: Control = $CanvasLayer/JoeHudFloatingHolder

@export var joe_scene: PackedScene
@export_range(1, 4, 1.0) var joe_count: int = 1:
	set(value):
		joe_count = value
		_model_updated.emit()

@export_enum("brown", "yellow", "violet", "red", "cyan")
var color_map: Array[String] = []

signal updated_selected_joe(joe: Joe)

var selected_joe: Joe:
	set(value):
		selected_joe = value
		updated_selected_joe.emit(value)

var alive: bool = true

func _ready() -> void:
	if not Engine.is_editor_hint():
		$CanvasLayer.show()

	update_view()
	_model_updated.connect(update_view)

	_on_selected_joe_changed(null)
	updated_selected_joe.connect(_on_selected_joe_changed)

func update_view() -> void:
	for child in joes.get_children():
		joes.remove_child(child)

	var joe: Joe
	var hud: JoeHud
	var floating_hud: JoeHud
	for i in joe_count:
		joe = joe_scene.instantiate()
		joes.add_child(joe)
		joe.position.x = 35 * i
		if i < color_map.size():
			joe.color = color_map.get(i)

		if Engine.is_editor_hint(): continue

		joe.died.connect(_on_joe_died)

		hud = joe_hud_holder.get_child(i)
		hud.joe = joe
		floating_hud = joe_hud_floating_holder.get_child(i)
		floating_hud.joe = joe


func _on_joe_died(is_finished: bool, joe: Joe) -> void:
	if is_finished:
		_player_died.emit()
	else:
		alive = false
		joe_exploded.emit()
		selected_joe = joe
		for child: Joe in joes.get_children():
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.animation_player.process_mode = Node.PROCESS_MODE_ALWAYS
			child.animation_tree.process_mode = Node.PROCESS_MODE_ALWAYS
			child.control_lock(true)
		selected_joe.process_mode = Node.PROCESS_MODE_INHERIT


func add_a_joe(reference_joe: Joe) -> void:
	var i = joes.get_child_count()

	var hud: JoeHud = joe_hud_holder.get_child(i)
	var floating_hud: JoeHud = joe_hud_floating_holder.get_child(i)
	var joe: Joe = reference_joe.duplicate()
	joe.is_waiting = false
	await get_tree().physics_frame
	joes.add_child(joe)
	joe.global_position = selected_joe.global_position + Vector2.UP * 40
	joe.died.connect(_on_joe_died)

	hud.joe = joe
	floating_hud.joe = joe


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	process_switch(&"swap_char_1", 0)
	process_switch(&"swap_char_2", 1)
	process_switch(&"swap_char_3", 2)
	process_switch(&"swap_char_4", 3)

	if selected_joe:
		selected_joe.process_movent(delta)


func process_switch(action: StringName, index: int) -> void:
	if index > joes.get_child_count() - 1:
		return

	var joe: Joe = joes.get_child(index)

	if selected_joe and selected_joe.health <= 0: return
	if not Input.is_action_just_pressed(action): return
	if selected_joe == joe: return

	if selected_joe:
		# remove the old from the group
		selected_joe.remove_from_group('active_actor')
	selected_joe = joe
	if SaveManager.data.new_game_plus <= 1:
		selected_joe.velocity.y -= 200
	selected_joe.add_to_group('active_actor')


func _on_selected_joe_changed(_joe: Joe) -> void:
	for joe: Joe in joes.get_children():
		joe.do_life_drain = !!selected_joe
		joe.set_collision_layer_value(TUTORIAL_LAYER, false)

	if selected_joe:
		selected_joe.set_collision_layer_value(TUTORIAL_LAYER, true)


func get_rect_containing_all_joes() -> Rect2:
	if not joes:
		return Rect2()

	var list = joes.get_children() as Array[Joe]
	var ajoe = list.pop_front()
	var rect:= Rect2(ajoe.global_position, Vector2.ONE * 50)

	for joe: Joe in list:
		rect = rect.expand(joe.global_position)

	rect.position.y -= 30
	return rect
