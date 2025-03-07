extends CharacterBody2D
class_name Character

signal die()

const MAX_COYOTE_TIME = 0.15
const MAX_JUMPS = 1

const SPEED = 200.0
const JUMP_VELOCITY = -500.0

@export var do_life_drain: bool = true

@export var swap_prompt: Texture2D

@export_enum("jump_king", "hollow_knight") var jump_mode: String

var jump_force_accumulator: float = 0
@export var gravity_multi_curve: Curve = Curve.new()

var delta_since_last_on_floor: float = 0.0
var jump_count: int = 0
var can_jump: bool:
	get():
		return jump_count < MAX_JUMPS and delta_since_last_on_floor < MAX_COYOTE_TIME


@onready var health: ProgressBar = %Health
@onready var health2: ProgressBar = %Health2

@onready var prompt_sprite: TextureRect = %TextureRect
@onready var prompt_sprite2: TextureRect = %TextureRect2

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var animation_tree: AnimationTree = $AnimationTree

func _ready() -> void:
	health.value = health.max_value
	health2.value = health.max_value
	prompt_sprite.texture = swap_prompt
	prompt_sprite2.texture = swap_prompt


func _physics_process(delta: float) -> void:
	if do_life_drain:
		if velocity.length() < 0.01:
			set_health(-delta, true)
		else:
			set_health(health.max_value, false)

	# Add the gravity.
	if not is_on_floor():
		var remaped = clamp(remap(velocity.y, -500, 500, 0, 1), 0, 1)
		var mult = 1 + gravity_multi_curve.sample_baked(remaped)
		velocity += get_gravity() * mult * delta

	# drag
	velocity.x *= 0.8 if is_on_floor() else 0.99

	if abs(velocity.x) < 1:
		velocity.x = 0

	move_and_slide()

	if abs(velocity.x) > 0:
		animation_tree.set('parameters/dir/blend_position', velocity.x)
	animation_tree.set('parameters/StateMachine/air_anim/blend_position', velocity.y)
	animation_tree.set('parameters/StateMachine/conditions/walking', velocity.x != 0)
	animation_tree.set('parameters/StateMachine/conditions/idling', velocity.x == 0)
	animation_tree.set('parameters/StateMachine/conditions/falling', velocity.y > 0)
	animation_tree.set('parameters/StateMachine/conditions/jumping', velocity.y < 0)
	animation_tree.set('parameters/StateMachine/conditions/landing', velocity.y == 0)
	animation_tree.set('parameters/StateMachine/conditions/winding', jump_force_accumulator > 0)

func process_movement(delta: float) -> void:
	# coyote time
	if is_on_floor():
		delta_since_last_on_floor = 0
		jump_count = 0
	else:
		delta_since_last_on_floor += delta

	# Handle jump.
	if jump_mode == 'jump_king':
		if can_jump:
			if Input.is_action_pressed("jump"):
				jump_force_accumulator = min(jump_force_accumulator + delta * 10, 1)
			if Input.is_action_just_released("jump"):
				velocity.y = JUMP_VELOCITY * jump_force_accumulator
				jump_force_accumulator = 0
				jump_count += 1
	elif jump_mode == 'hollow_knight':
		if can_jump:
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY
				jump_count += 1
		if Input.is_action_just_released("jump"):
			velocity.y = max(velocity.y, -100)

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x > 0:
		area_2d.scale.x = 1
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		area_2d.scale.x = -1
		sprite_2d.flip_h = true
	
	if Input.is_action_just_pressed("smack"):
		var bodies = area_2d.get_overlapping_bodies()
		for body in bodies:
			if body == self: continue
			if body is Character:
				body.velocity.y = -350
				body.velocity.x = 600 * area_2d.scale.x


func _on_health_value_changed(value: float) -> void:
	match value:
		# run out of health
		health.min_value:
			sprite_2d.visible = false
			health.visible = false
			prompt_sprite.visible = false
			animated_sprite_2d.visible = true
			animated_sprite_2d.play()
			prompt_sprite.modulate.a = 0
			self.process_mode = Node.PROCESS_MODE_DISABLED
			animated_sprite_2d.animation_finished.connect(func():
				die.emit())
		# getting close to no health
		var x when x < (health.max_value / 5):
			prompt_sprite.modulate.a = 1
		_:
			prompt_sprite.modulate.a = 0.5

@onready var panel_container: PanelContainer = %PanelContainer2


func set_health(value: float, do_increment: bool) -> void:
	if do_increment:
		health.value += value
		health2.value += value
	else:
		health.value = value
		health2.value = value

func set_prompt_visibility(visible: bool) -> void:
	prompt_sprite.visible = visible
	prompt_sprite2.visible = visible
	panel_container.visible = visible
