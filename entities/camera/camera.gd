extends Camera2D
class_name CameraMain

static var singleton: CameraMain:
	set(value):
		assert(not singleton or value == null, 'Error: singleton already loaded, only one instance allowed')
		singleton = value


@export var player: PlayerController
@export var zoom_constant: float = 0.8

var main_poi: Vector2
var poi_list: Array[Vector2] = []


func _ready() -> void:
	singleton = self
	player.joe_exploded.connect(_on_player_death)

func _exit_tree() -> void:
	singleton = null


func momentarily_add_to_focus(point: Vector2) -> void:
	var tween = create_tween()
	tween.tween_callback(func():
		poi_list.push_back(point))
	tween.tween_interval(3)
	tween.tween_callback(func():
		poi_list.erase(point))


func _on_player_death() -> void:
	var original_offset = self.offset
	var max_shake = SettingsManager.get_screen_shake()
	var tween = create_tween()
	
	const SHAKE_DURATION = 0.5
	const SHAKE_COUNT = 10
	const SHAKE_EACH_DURATION = SHAKE_DURATION / SHAKE_COUNT
	
	for i in SHAKE_COUNT:
		var mod = (SHAKE_COUNT - i) / float(SHAKE_COUNT)
		tween.tween_property(
			self,
			'offset',
			Vector2.from_angle(TAU * randf()) * max_shake * mod,
			SHAKE_EACH_DURATION)
	tween.tween_property(self, 'offset', original_offset, 0.1)


func get_rect_containing_points_of_interest() -> Rect2:
	var list = poi_list.duplicate()
	var rect:= Rect2(main_poi, Vector2.ONE)

	for point: Vector2 in list:
		rect = rect.expand(point)

	rect.position.y -= 35
	rect.size.y += 70
	return rect


func _physics_process(_delta: float) -> void:
	if player.selected_joe:
		main_poi = player.selected_joe.global_position
	else:
		var rect = player.get_rect_containing_all_joes()
		main_poi = rect.get_center()

	var rect = get_rect_containing_points_of_interest()
	var poi = rect.get_center()
	self.global_position += (poi - self.global_position) * 0.2

	if poi_list.size():
		var zoom_factor_x = get_viewport_rect().size.x / rect.size.x * zoom_constant
		var zoom_factor_y = get_viewport_rect().size.y / rect.size.y * zoom_constant
		var zoom_factor = clamp(min(zoom_factor_x, zoom_factor_y), 0.01, 1)
		self.zoom = Vector2(zoom_factor, zoom_factor)
	else:
		self.zoom = Vector2.ONE
