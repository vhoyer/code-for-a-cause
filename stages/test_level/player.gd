extends Node2D

@export var joe1: CharacterBody2D
@export var joe2: CharacterBody2D
@export var joe3: CharacterBody2D
@export var joe4: CharacterBody2D

var select_joe: CharacterBody2D


func _physics_process(delta: float) -> void:
	process_swap(&'swap_char_1', joe1)
	process_swap(&'swap_char_2', joe2)
	process_swap(&'swap_char_3', joe3)
	process_swap(&'swap_char_4', joe4)

	if select_joe:
		select_joe.process_movement(delta)

func process_swap(action: StringName, joe: CharacterBody2D) -> void:
	if Input.is_action_just_pressed(action):
		select_joe.prompt_sprite.visible = true
		select_joe = joe
		select_joe.prompt_sprite.visible = false
