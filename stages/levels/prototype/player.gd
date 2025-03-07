extends Node2D
class_name TestPlayer

@onready var joes: Node2D = $joes
@onready var h_box_container: HBoxContainer = %HBoxContainer


@export var joe1: Character
@export var joe2: Character
@export var joe3: Character
@export var joe4: Character

var select_joe: Character

func _physics_process(delta: float) -> void:
	process_swap(&'swap_char_1', joe1)
	process_swap(&'swap_char_2', joe2)
	process_swap(&'swap_char_3', joe3)
	process_swap(&'swap_char_4', joe4)

	if select_joe:
		select_joe.process_movement(delta)

func process_swap(action: StringName, joe: CharacterBody2D) -> void:
	if not joe: return
	if Input.is_action_just_pressed(action):
		if select_joe:
			select_joe.set_prompt_visibility(true)
		select_joe = joe
		select_joe.velocity.y -= 200
		select_joe.set_prompt_visibility(false)


func _ready() -> void:
	var list = joes.get_children() as Array[Character]
	for joe: Character in list:
		joe.die.connect(died)
		joe.panel_container.reparent(h_box_container)


func died() -> void:
	StageManager.go_back(1, {
		'score': int(%Label.text)
	})
	pass

func get_rect_containing_all_joes() -> Rect2:
	var list = joes.get_children() as Array[CharacterBody2D]
	var ajoe = list.pop_front()
	var rect:= Rect2(ajoe.global_position, Vector2(50, 50))

	for joe: CharacterBody2D in list:
		rect = rect.expand(joe.global_position)

	rect.position.y -= 30
	return rect
