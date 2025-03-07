extends Camera2D

@export_enum("contain_all", "follow_selected")
var camera_mode: String

@export var player: TestPlayer
@export var zoom_constant: float = 0.8

func _ready() -> void:
	var rect = player.get_rect_containing_all_joes()
	self.position = rect.get_center()


func _physics_process(delta: float) -> void:
	if camera_mode == 'follow_selected' and player.select_joe:
		self.position += (player.select_joe.position - self.position) * 0.2
		self.zoom = Vector2.ONE
	
	if camera_mode == 'contain_all' or not player.select_joe:
		var rect = player.get_rect_containing_all_joes()
		self.position = rect.get_center()

		var zoom_factor_x = get_viewport_rect().size.x / rect.size.x * zoom_constant
		var zoom_factor_y = get_viewport_rect().size.y / rect.size.y * zoom_constant
		var zoom_factor = clamp(min(zoom_factor_x, zoom_factor_y), 0.1, 1)
		self.zoom = Vector2(zoom_factor, zoom_factor)
