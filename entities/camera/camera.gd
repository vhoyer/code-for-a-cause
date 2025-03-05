extends Camera2D
class_name CameraMain

static var singleton: CameraMain:
	set(value):
		assert(not singleton or value == null, 'Error: singleton already loaded, only one instance allowed')
		singleton = value


@export var player: PlayerController
@export var zoom_constant: float = 0.8


func _init() -> void:
	singleton = self

func _exit_tree() -> void:
	singleton = null


func _physics_process(_delta: float) -> void:
	if player.selected_joe:
		self.global_position += (player.selected_joe.global_position - self.global_position) * 0.2
		self.zoom = Vector2.ONE
	else:
		var rect = player.get_rect_containing_all_joes()
		self.global_position = rect.get_center()

		var zoom_factor_x = get_viewport_rect().size.x / rect.size.x * zoom_constant
		var zoom_factor_y = get_viewport_rect().size.y / rect.size.y * zoom_constant
		var zoom_factor = clamp(min(zoom_factor_x, zoom_factor_y), 0.1, 1)
		self.zoom = Vector2(zoom_factor, zoom_factor)
