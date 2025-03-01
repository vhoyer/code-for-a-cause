extends Resource
class_name YatcPointsCustomReward

@export var broadcaster_name: String = "torpedo09"
@export var broadcaster_login: String = "torpedo09"
@export var broadcaster_id: String = "274637212"
@export var id: String = "92af127c-7326-4483-a52b-b0da0be61c01"
## "image": {
## 	"url_1x": "https://static-cdn.jtvnw.net/custom-reward-images/default-1.png",
## 	"url_2x": "https://static-cdn.jtvnw.net/custom-reward-images/default-2.png",
## 	"url_4x": "https://static-cdn.jtvnw.net/custom-reward-images/default-4.png"
## }
@export var image: Dictionary
@export var background_color: String = "#00E5CB"
@export var is_enabled: bool = true
@export var cost: int = 50000
@export var title: String = "game analysis"
@export var prompt: String = ""
@export var is_user_input_required: bool = false
## "max_per_stream_setting": {
## 	"is_enabled": false,
## 	"max_per_stream": 0
## }
@export var max_per_stream_setting: Dictionary
## "max_per_user_per_stream_setting": {
## 	"is_enabled": false,
## 	"max_per_user_per_stream": 0
## }
@export var max_per_user_per_stream_setting: Dictionary
## "global_cooldown_setting": {
## 	"is_enabled": false,
## 	"global_cooldown_seconds": 0
## }
@export var global_cooldown_settin: Dictionary
@export var is_paused: bool = false
@export var is_in_stock: bool = true
## "default_image": {
## 	"url_1x": "https://static-cdn.jtvnw.net/custom-reward-images/default-1.png",
## 	"url_2x": "https://static-cdn.jtvnw.net/custom-reward-images/default-2.png",
## 	"url_4x": "https://static-cdn.jtvnw.net/custom-reward-images/default-4.png"
## }
@export var default_image: Dictionary
@export var should_redemptions_skip_request_queue: bool = false
@export var redemptions_redeemed_current_stream: int
@export var cooldown_expires_at: String

func _init(json: Dictionary):
	for entry in self.get_property_list():
		if !json.has(entry.name): continue
		var value = json.get(entry.name)
		if value == null: continue
		self[entry.name] = value
