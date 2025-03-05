extends Node2D
class_name PlayerController

@onready var joes: Node = $Joes

var selected_joe: Joe

func _ready() -> void:
	var list = joes.get_children() as Array[Character]
	for joe: Joe in list:
		selected_joe = joe


func _physics_process(delta: float) -> void:
	if selected_joe:
		selected_joe.process_movent(delta)


func get_rect_containing_all_joes() -> Rect2:
	if not joes:
		return Rect2()

	var list = joes.get_children() as Array[Joe]
	var ajoe = list.pop_front()
	var rect:= Rect2(ajoe.global_position, Vector2(50, 50))

	for joe: Joe in list:
		rect = rect.expand(joe.global_position)

	rect.position.y -= 30
	return rect
