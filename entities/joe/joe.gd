extends CharacterBody2D
class_name Joe

const MAX_COYOTE_TIME = 0.15
const MAX_JUMPS = 1

const SPEED = 200.0
const JUMP_VELOCITY = -500.0
const DRAG_FLOOR = 0.8
const DRAG_AIR = 0.99

const MAX_HEALTH = 11.0


signal health_updated(health: float)


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var visual_root: Node2D = $VisualRoot
@onready var hitbox_punch: Area2D = $VisualRoot/HitboxPunch
@onready var health_reporter_timeout: Timer = $HealthReporterTimeout


@export
var is_grabbed: bool = false
@export
var is_grabbing: bool = false

@export
var do_life_drain: bool = true
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


func _ready() -> void:
	health = MAX_HEALTH
	update_animation_tree_parameters()


func _process(_delta: float) -> void:
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

	animation_tree.set('parameters/BlendTree/animations/conditions/is_punching', Input.is_action_just_pressed("smack"))
	animation_tree.set('parameters/BlendTree/animations/conditions/is_hurting', false)
	animation_tree.set('parameters/BlendTree/animations/conditions/is_grabbing', is_grabbing)
	animation_tree.set('parameters/BlendTree/animations/conditions/is_exploding', health <= 0)

	animation_tree.set('parameters/conditions/is_grabbed', is_grabbed)
	animation_tree.set('parameters/conditions/not_grabbed', !is_grabbed)


func _physics_process(delta: float) -> void:
	if do_life_drain:
		if velocity.length() < 0.01:
			health -= delta
		else:
			health = MAX_HEALTH

	# Add the gravity.
	if not is_on_floor():
		var remaped = clamp(remap(velocity.y, -500, 500, 0, 1), 0, 1)
		var mult = 1 + gravity_by_velocity_mapping.sample_baked(remaped)
		velocity += get_gravity() * mult * delta

	# drag
	velocity.x *= DRAG_FLOOR if is_on_floor() else DRAG_AIR

	if abs(velocity.x) < 1:
		velocity.x = 0

	move_and_slide()


func process_movent(delta: float) -> void:
	if is_on_floor():
		delta_since_last_on_floor = 0
		jump_count = 0
	else:
		delta_since_last_on_floor += delta

	process_jump()
	process_walking()

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
	var bodies = hitbox_punch.get_overlapping_bodies()

	for body in bodies:
		if body == self: continue
		if body is Character:
			body.velocity.y = -350
			body.velocity.x = 600 * visual_root.scale.x


func control_lock(lock) -> void:
	is_control_locked = lock


func _on_hitbox_grab_body_entered(body: Node2D) -> void:
	if body.is_in_group('grabbable'):
		is_grabbing = true
		# TODO: move body to the grab position


func throw_grabbed() -> void:
	is_grabbing = false
	# TODO: make obj go birr
