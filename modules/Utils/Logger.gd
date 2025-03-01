extends Resource
class_name Logger

@export var name: String

func _init(name: String = "") -> void:
	self.name = name


func info(msg: String) -> void:
	print_rich('[b][lb]', name, '[rb]:[/b] ', msg)


func debug(msg: String) -> void:
	print_rich('[color=dimgray]', '[b][lb]', name, '[rb]:[/b] ', msg, '[/color]')


func warn(msg: String) -> void:
	print_rich('[color=gold]', '[b][lb]', name, '[rb]:[/b] ', msg, '[/color]')


func error(msg: String) -> void:
	print_rich('[color=firebrick]', '[b][lb]', name, '[rb]:[/b] ', msg, '[/color]')


static func scope(name: String) -> Logger:
	return Logger.new(name)
