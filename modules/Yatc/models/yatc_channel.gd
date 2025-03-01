extends Resource
class_name YatcChannel

@export_storage var id: int
@export_storage var username: String
@export_storage var token: String

@export_storage var created_at: float
@export_storage var expires_in: int = -1

var custom_rewards: Array[YatcPointsCustomReward]

func _init(username: String = ""):
	created_at = Time.get_unix_time_from_system()
	self.username = username


func is_valid() -> bool:
	return created_at + expires_in > Time.get_unix_time_from_system()


func save() -> void:
	assert(username, "Error: can't save channel without login")
	ResourceSaver.save(self, get_resource_path(username))


static func load(username: String) -> YatcChannel:
	var path = get_resource_path(username)
	if not FileAccess.file_exists(path):
		print("[]")
		return YatcChannel.new()
	return ResourceLoader.load(path)


static func get_resource_path(username: String) -> String:
	# TODO: make this based on the scope
	return "user://yatc-%s.tres" % username
