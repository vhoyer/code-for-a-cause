extends Node2D
class_name PlayerController

@onready var joes: Node2D = $Joes
@onready var joe_hud_holder: HBoxContainer = $CanvasLayer/JoeHudHolder
@onready var joe_hud_floating_holder: Control = $CanvasLayer/JoeHudFloatingHolder

@export var joe_scene: PackedScene
@export_range(1, 4, 1.0) var joe_count: int = 1

signal updated_selected_joe(joe: Joe)

var selected_joe: Joe:
	set(value):
		selected_joe = value
		updated_selected_joe.emit(value)

func _ready() -> void:
	for child in joes.get_children():
		joes.remove_child(child)

	var joe: Joe
	var hud: JoeHud
	var floating_hud: JoeHud
	for i in joe_count:
		joe = joe_scene.instantiate()
		joes.add_child(joe)
		joe.position.x = -30 * i
		
		hud = joe_hud_holder.get_child(i)
		hud.joe = joe
		floating_hud = joe_hud_floating_holder.get_child(i)
		floating_hud.joe = joe


func _physics_process(delta: float) -> void:
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

	if joe.health <= 0: return
	if not Input.is_action_just_pressed(action): return

	selected_joe = joe
	selected_joe.velocity.y -= 200


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
