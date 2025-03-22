@tool
extends GridContainer

@export_dir var level_dir;

@export_tool_button('Populate Level List')
var populate_btn = populate_grid

func populate_grid() -> void:
	for child in self.get_children():
		self.remove_child(child)

	var dir = DirAccess.open(level_dir)
	if !dir:
		printerr("The gods have failed us, no dir '%s' found" % [level_dir]);
		pass
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "": break
		if !dir.current_is_dir(): continue
		var path = "%s/%s/%s.tscn" % [dir.get_current_dir(true), file_name, file_name]
		if not FileAccess.file_exists(path): continue
		add_game(path, file_name)
	dir.list_dir_end()
	pass

func add_game(path: String, title: String):
	var btn = Button.new()
	btn.set_script(ButtonSceneChanger)
	btn.name = title.replace('_', ' ')
	self.add_child(btn, true)
	btn.scene = load(path)
	btn.text = btn.name
	btn.custom_minimum_size = Vector2(150, 15)
	btn.owner = self.owner;
