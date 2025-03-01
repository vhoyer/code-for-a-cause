extends Node
class_name MakeParentTweenOnTrigger

@export
var animation: StateTween

@export_enum("mouse_activity", "manual")
var trigger: String = "manual"

@export
var idle_timeout: float = 2

var timer: Timer

var paused: bool:
	get():
		return timer.paused
	set(value):
		timer.paused = value

func _ready() -> void:
	animation.reset(self.get_parent())
	
	if trigger == 'mouse_activity':
		timer = Timer.new()
		self.add_child(timer)
		timer.wait_time = idle_timeout
		timer.timeout.connect(_on_timer_timeout)
		timer.start()

func _input(event: InputEvent) -> void:
	if trigger == 'mouse_activity':
		timer.start()
		appear()

func _on_timer_timeout() -> void:
	disappear()

func appear() -> Tween:
	return animation.enter(create_tween())

func disappear() -> Tween:
	return animation.exit(create_tween())
