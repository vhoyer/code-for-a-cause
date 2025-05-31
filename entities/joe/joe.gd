@tool
extends CharacterBody2D
class_name Joe

signal _model_updated()

const MAX_COYOTE_TIME = 0.15
const MAX_JUMPS = 1

const SPEED = 200.0
const JUMP_VELOCITY = -500.0
const DRAG_FLOOR = 0.8
const DRAG_AIR = 0.99

const MAX_HEALTH = 20.0


signal health_updated(health: float)
signal died(is_finished: bool, joe: Joe)


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visual_root: Node2D = $VisualRoot
@onready var hitbox_punch: Area2D = $VisualRoot/HitboxPunch
@onready var grab_position: Marker2D = $GrabPosition

@onready var jump: AudioStreamPlayer = $Jump
@onready var just_explosion: AudioStreamPlayer = $JustExplosion
@onready var punch: AudioStreamPlayer = $Punch

@export_enum("brown", "yellow", "violet", "red", "cyan")
var color: String = 'brown':
	set(value):
		color = value
		_model_updated.emit()

@export
var is_grabbed: bool = false
@export
var is_grabbing: bool = false
var grab_list:= Set.new()

@export
var is_waiting: bool = false

@export
var do_life_drain: bool = false
@export
var gravity_by_velocity_mapping: Curve = Curve.new()

var is_control_locked: bool = false

var delta_since_last_on_floor: float = 0.0
var jump_count: int = 0
var can_jump: bool:
	get():
		return jump_count < MAX_JUMPS and delta_since_last_on_floor < MAX_COYOTE_TIME


var health: float:
	set(value):
		health = value
		health_updated.emit(health)


var last_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	_model_updated.connect(update_view)
	_model_updated.emit()

	if Engine.is_editor_hint(): return

	health = MAX_HEALTH
	update_animation_tree_parameters()


func update_view() -> void:
	const INPUT_PALETTE = preload("res://entities/joe/assets/Joe Palette/Input Palette.png")
	var output_palette = $VisualRoot.color_dict.get(color, INPUT_PALETTE)
	self.material.set('shader_parameter/output_palette_texture', output_palette)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	update_animation_tree_parameters()
	pass


func update_animation_tree_parameters() -> void:
	if abs(velocity.x) > 0:
		animation_tree.set('parameters/BlendTree/direction/blend_position', velocity.x)
		animation_tree.set('parameters/BlendTree/animations/walking/blend_position', velocity.x)
	animation_tree.set('parameters/BlendTree/animations/air/blend_position', velocity.y)

	animation_tree.set('parameters/BlendTree/animations/conditions/is_idle', abs(velocity.x) == 0 and is_on_floor())
	animation_tree.set('parameters/BlendTree/animations/conditions/is_walking', abs(velocity.x) > 0 and is_on_floor())
	animation_tree.set('parameters/BlendTree/animations/conditions/is_jumping', jump_count > 0)

	animation_tree.set('parameters/BlendTree/animations/conditions/is_on_air', !is_on_floor())
	animation_tree.set('parameters/BlendTree/animations/conditions/is_on_floor', is_on_floor())

	animation_tree.set('parameters/BlendTree/animations/conditions/is_hurting', false)
	animation_tree.set('parameters/BlendTree/animations/conditions/is_grabbing', is_grabbing)
	animation_tree.set('parameters/conditions/is_exploding', health <= 0)

	animation_tree.set('parameters/conditions/is_grabbed', is_grabbed)
	animation_tree.set('parameters/conditions/not_grabbed', !is_grabbed)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if do_life_drain:
		if velocity.length() < 0.01:
			health -= delta
		else:
			health = MAX_HEALTH

	# Add the gravity.
	if not is_on_floor() or not is_grabbed:
		var remaped = clamp(remap(velocity.y, -500, 500, 0, 1), 0, 1)
		var mult = 1 + gravity_by_velocity_mapping.sample_baked(remaped)
		velocity += get_gravity() * mult * delta
	elif is_grabbed:
		velocity.y = 0
		for body in grab_list.values():
			if body is Joe:
				body.global_position = grab_position.global_position

	# drag
	velocity.x *= DRAG_FLOOR if is_on_floor() else DRAG_AIR

	if abs(velocity.x) < 1:
		velocity.x = 0

	if is_waiting:
		velocity = Vector2.ZERO

	move_and_slide()

	if last_velocity.y >= 0 and velocity.y < 0:
		jump.play()
	last_velocity = velocity


func process_movent(delta: float) -> void:
	if is_on_floor():
		delta_since_last_on_floor = 0
		jump_count = 0
	else:
		delta_since_last_on_floor += delta

	process_jump()
	process_walking()
	animation_tree.set('parameters/BlendTree/animations/conditions/is_punching', Input.is_action_just_pressed("smack"))

func process_jump() -> void:
	# handle jump
	if can_jump and not is_control_locked:
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			jump_count += 1
	if Input.is_action_just_released("jump"):
		velocity.y = max(velocity.y, -100)

func process_walking() -> void:
	if is_control_locked: return
	# handle horizontal movement
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func smack() -> void:
	punch.play()
	var bodies = hitbox_punch.get_overlapping_bodies()

	for body in bodies:
		if body == self: continue
		if body is Joe:
			body.velocity.y = -350
			body.velocity.x = 600 * visual_root.scale.x


func control_lock(lock: bool) -> void:
	is_control_locked = lock


func _on_hitbox_grab_body_entered(body: Node2D) -> void:
	if body == self: return
	if body.is_in_group('grabbable'):
		is_grabbing = true
		if body is Joe:
			body.is_grabbed = true
			grab_list.add(body)
			body.global_position = grab_position.global_position
			body.velocity = Vector2.ZERO
			body.animation_tree.set(
				'parameters/BlendTree/direction/blend_position',
				self.animation_tree.get('parameters/BlendTree/direction/blend_position'))
			body.control_lock(true)


func _on_hitbox_grab_body_exited(body: Node2D) -> void:
	if body == self: return
	if body.is_in_group('grabbable'):
		is_grabbing = false
		if body is Joe:
			body.is_grabbed = false
			grab_list.erase(body)
			body.control_lock(false)


func throw_grabbed() -> void:
	while grab_list.size():
		var body: CharacterBody2D = grab_list.pop_front()
		body.is_grabbed = false
		body.velocity.y = JUMP_VELOCITY * 1.2


func die_begin() -> void:
	just_explosion.play()
	died.emit(false, self)


func die_end() -> void:
	died.emit(true, self)


func _on_hitbox_entered(_body: Node2D) -> void:
	control_lock(true)
	do_life_drain = false
	health = 0
