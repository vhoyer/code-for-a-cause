extends Resource
class_name YatcChatMessage

## { id: String, info: String, set_id: String }[]
@export var badges: Array
@export var broadcaster_user_id: String
## all lower case
@export var broadcaster_user_login: String
## user display name, equal to login except on casing
@export var broadcaster_user_name: String
@export var channel_points_animation_id = null
@export var channel_points_custom_reward_id = null
@export var chatter_user_id: String
@export var chatter_user_login: String
@export var display_name: String
@export var cheer = null
@export var color: String
## { "fragments": [ { "cheermote" = null, "emote" = null, "mention" = null, "text": "s", "type": "text" } ], "text": "s" }
@export var message: Dictionary
@export var message_id: String
@export var message_type: String
@export var reply = null
@export var source_badges = null
@export var source_broadcaster_user_id = null
@export var source_broadcaster_user_login = null
@export var source_broadcaster_user_name = null
@export var source_message_id = null

var raw_text: String:
	get():
		return message.text

func _init(json: Dictionary):
	badges = json['badges']
	broadcaster_user_id = json['broadcaster_user_id']
	broadcaster_user_login = json['broadcaster_user_login']
	broadcaster_user_name = json['broadcaster_user_name']
	channel_points_animation_id = json['channel_points_animation_id']
	channel_points_custom_reward_id = json['channel_points_custom_reward_id']
	chatter_user_id = json['chatter_user_id']
	chatter_user_login = json['chatter_user_login']
	display_name = json['chatter_user_name']
	cheer = json['cheer']
	color = json['color']
	message = json['message']
	message_id = json['message_id']
	message_type = json['message_type']
	reply = json['reply']
	source_badges = json['source_badges']
	source_broadcaster_user_id = json['source_broadcaster_user_id']
	source_broadcaster_user_login = json['source_broadcaster_user_login']
	source_broadcaster_user_name = json['source_broadcaster_user_name']
	source_message_id = json['source_message_id']
