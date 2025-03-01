extends Node
class_name YatcAPI

const URL_VALIDATE = 'https://id.twitch.tv/oauth2/validate'

func validate(token: String) -> YatcChannel:
	var http = HTTPRequest.new()
	self.add_child(http)

	http.request(URL_VALIDATE, [
		'Authorization: OAuth ' + token
	])

	var result = await http.request_completed
	var body = (result[3] as PackedByteArray).get_string_from_utf8()

	var status = result[1]
	match status:
		401:
			var json = JSON.parse_string(body)
			Logger.scope('Yatc').info(json['message'])
			return YatcChannel.new()
		200:
			var json = JSON.parse_string(body)
			var channel = YatcChannel.new()
			channel.id = json['user_id']
			channel.username = json['login']
			channel.expires_in = json['expires_in']
			channel.token = token

			http.queue_free()
			return channel
		_:
			assert(false, 'Error: no can connect to twitch, sorry')
			return YatcChannel.new()


const URL_GET_USERS = 'https://api.twitch.tv/helix/users'

## Gets information about one or more users.
##
## You may look up users using their user ID, login name, or both but the sum total of the number of users you may look up is 100. For example, you may specify 50 IDs and 50 names or 100 IDs or names, but you cannot specify 100 IDs and 100 names.
##
## If you don’t specify IDs or login names, the request returns information about the user in the access token if you specify a user access token.
##
## To include the user’s verified email address in the response, you must use a user access token that includes the user:read:email scope.
func get_users(usernames: Array[String]) -> Array[YatcChannel]:
	var http = HTTPRequest.new()
	self.add_child(http)

	var url = URL.new(URL_VALIDATE)
	url.query['login'] = usernames

	http.request(url.href, [
		'Authorization: Bearer %s' % Yatc.singleton.token,
		'Client-Id: %s' % Yatc.singleton.client_id,
	])

	var result = await http.request_completed
	var body = (result[3] as PackedByteArray).get_string_from_utf8()

	var status = result[1]
	match status:
		200:
			var json = JSON.parse_string(body)
			http.queue_free()
			return json['data'].map(func(user):
				var channel = YatcChannel.new()
				channel.id = user['user_id']
				channel.username = user['login']
				return channel
				)
		400, 401:
			var json = JSON.parse_string(body)
			Logger.scope('Yatc').info(json['message'])
			return []
		_:
			assert(false, 'Error: wtf? I also donno what happened')
			return []


## Gets a list of custom rewards that the specified broadcaster created.
## https://dev.twitch.tv/docs/api/reference/#get-custom-reward
func get_custom_reward() -> Array[YatcPointsCustomReward]:
	_has_needed_scope(['channel:read:redemptions', 'channel:manage:redemptions'])

	var url = URL.new('https://api.twitch.tv/helix/channel_points/custom_rewards')
	url.query['broadcaster_id'] = Yatc.singleton.user.id

	var result = await _request(url)

	match result.status:
		200:
			Logger.scope('Yatc.get_custom_reward').info('Retrieved the following:')
			Logger.scope('Yatc.get_custom_reward').info(JSON.stringify(result.to_json.call()))
			var reward_list: Array[YatcPointsCustomReward] = []

			for json in result.to_json.call('data'):
				reward_list.push_back(YatcPointsCustomReward.new(json))

			return reward_list
		400, 401, 403, 404:
			Logger.scope('Yatc.get_custom_reward').warn(result.to_json.call('message'))
			return []
		_:
			assert(false, 'Error: wtf? I also donno what happened')
			return []


func _request(url: URL) -> Dictionary:
	var http = HTTPRequest.new()
	self.add_child(http)
	http.request_completed.connect(func():
		self.remove_child(http))

	http.request(url.href, [
		'Authorization: Bearer %s' % Yatc.singleton.token,
		'Client-Id: %s' % Yatc.singleton.client_id,
	])

	var result = await http.request_completed
	var body = (result[3] as PackedByteArray).get_string_from_utf8()

	return {
		'status': result[1],
		'body': body,
		'to_json': func(key: String = ''):
			var json = JSON.parse_string(body)
			if key:
				return json[key]
			else:
				return json,
	}


func _has_needed_scope(required_scopes: Array[String]) -> void:
	assert(Yatc.singleton.scope.any(func(scope):
		return required_scopes.has(scope)),
		'Error: to call this function you need to have one of the following scopes authorized: ' + ', '.join(required_scopes))
