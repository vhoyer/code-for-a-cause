extends Node2D

@onready var label: Label = %Label
var score: int = 0
var current_area: Area2D

func _ready() -> void:
	everyone_hiden()
	choose_a_new_obj()
	for child: Area2D in self.get_children():
		child.obj.connect(choose_a_new_obj)
		child.obj.connect(func():
			score += 1
			label.text = str(score))

func everyone_hiden() -> void:
	for child: Area2D in self.get_children():
		child.visible = false
		child.process_mode = Node.PROCESS_MODE_DISABLED


func choose_a_new_obj() -> void:
	everyone_hiden()

	var old_area = current_area
	while old_area == current_area:
		current_area = self.get_children().pick_random()
	current_area.visible = true
	current_area.process_mode = Node.PROCESS_MODE_INHERIT
