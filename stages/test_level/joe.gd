extends CharacterBody2D

const MAX_COYOTE_TIME = 0.15
const MAX_JUMPS = 1

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

var jump_force_accumulator: float = 0
@export var gravity_multi_curve: Curve = Curve.new()

var delta_since_last_on_floor: float = 0.0
var jump_count: int = 0
var can_jump: bool:
	get():
		return jump_count < MAX_JUMPS and delta_since_last_on_floor < MAX_COYOTE_TIME


@onready var health: ProgressBar = $Health

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	health.value = health.max_value


func _physics_process(delta: float) -> void:
	if velocity.length() < 0.01:
		health.value -= delta
	else:
		health.value = health.max_value

	# Add the gravity.
	if not is_on_floor():
		var remaped = clamp(remap(velocity.y, -500, 500, 0, 1), 0, 1)
		var mult = 1 + gravity_multi_curve.sample_baked(remaped)
		velocity += get_gravity() * mult * delta

	# coyote time
	if is_on_floor():
		delta_since_last_on_floor = 0
		jump_count = 0
	else:
		delta_since_last_on_floor += delta

	# Handle jump.
	if can_jump:
		if Input.is_action_pressed("jump"):
			jump_force_accumulator = min(jump_force_accumulator + delta * 10, 1)
		if Input.is_action_just_released("jump"):
			velocity.y = JUMP_VELOCITY * jump_force_accumulator
			jump_force_accumulator = 0
			jump_count += 1

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_health_value_changed(value: float) -> void:
	if value != health.min_value: return
	sprite_2d.visible = false
	animated_sprite_2d.visible = true
	animated_sprite_2d.play()
	self.process_mode = Node.PROCESS_MODE_DISABLED
