@tool
extends TileMapLayer
class_name GameTileMap

@export var player: PlayerController

@export_group('Drag Along', 'drag')
@export
var drag_speed: float = 20.0
## add a value of 1 to go positively in the x direction and -1 to go to the other side
@export
var drag_direction_custom_data_layer_name:= 'drag_direction'

## use 'sfx_id' as a custom data layer name for identifing what tiles should produce what sound
## keys in the sfx_db should match the name in the 'sfx_id' in the tiles
@export
var sfx_db: Dictionary[String, AudioStream] = {}


@export
var debug: bool = false:
	set(value):
		debug = value
		if debug:
			self.add_child(debug_contex)
		else:
			self.remove_child(debug_contex)
var debug_contex: Node2D = ForegroundTileMapLayerDebug.new()

class ForegroundTileMapLayerDebug extends Node2D:
	var conveyor_selected_cell: Vector2 = Vector2.ZERO:
		set(value):
			conveyor_selected_cell = value
			queue_redraw()
	func _draw() -> void:
		draw_circle(conveyor_selected_cell, 5, Color.RED)


func _ready() -> void:
	if not Engine.is_editor_hint():
		setup_all_cell()


func setup_all_cell() -> void:
	for cell_coord in self.get_used_cells():
		setup_tile_sfxs(cell_coord)


func setup_tile_sfxs(cell_coord: Vector2i) -> void:
	var cell_data = self.get_cell_tile_data(cell_coord)
	if not cell_data: return

	var sfx_id = cell_data.get_custom_data('sfx_id')
	if sfx_id == null: return
	var stream = sfx_db.get(sfx_id, null)
	if not stream: return
	
	var audio = AudioStreamPlayer2D.new()
	audio.volume_db = -15
	audio.autoplay = true
	audio.max_distance = 500
	audio.attenuation = 4
	audio.stream = stream
	audio.position = self.map_to_local(cell_coord)
	self.add_child(audio)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	drag_along_process(delta)


func drag_along_process(delta: float) -> void:
	for joe: Joe in player.joes.get_children():
		if not joe.is_on_floor(): continue

		var local_player_pos = self.to_local(joe.global_position) + Vector2.DOWN
		var floor_cell_coord
		var floor_cell_data
		for search in [Vector2.ZERO, Vector2.LEFT, Vector2.RIGHT]:
			# also search 5 pixels to the left and right when player is at the edge
			floor_cell_coord = self.local_to_map(local_player_pos + search * 5)
			floor_cell_data = self.get_cell_tile_data(floor_cell_coord)
			if floor_cell_data: break

		if debug and joe == player.selected_joe:
			debug_contex.conveyor_selected_cell = self.map_to_local(floor_cell_coord)

		if not floor_cell_data: continue

		var drag_along = floor_cell_data.get_custom_data(drag_direction_custom_data_layer_name)
		if drag_along == null: continue
		joe.position.x += drag_speed * drag_along * delta * 2
