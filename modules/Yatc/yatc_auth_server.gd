extends Node
class_name YatcAuthServer

const URL_AUTHORIZE = 'https://id.twitch.tv/oauth2/authorize'
const CALLBACK_PORT = 7777
const CALLBACK_URL = 'http://localhost:%d/' % CALLBACK_PORT


static func open_auth_url(client_id: String, scope: Array[String]) -> void:
	var query = '&'.join([
		'response_type=token',
		'client_id=' + client_id,
		'redirect_uri=' + CALLBACK_URL,
		'scope=' + '+'.join(scope)
	])
	OS.shell_open(URL_AUTHORIZE + '?' + query)


signal token_received(token: String)

var _server: TCPServer
var _clients: Array[StreamPeerTCP] = []

func _ready() -> void:
	_server = TCPServer.new()
	var err = _server.listen(CALLBACK_PORT)
	assert(err == OK, 'Error: cannot start auth server')

func _exit_tree() -> void:
	if _server:
		_server.stop()

func _process(_delta: float) -> void:
	if !_server: return

	var conn = _server.take_connection()
	if conn:
		_clients.push_back(conn)

	for client in _clients:
		if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			continue

		var bytes = client.get_available_bytes()
		_clients = _clients.filter(func(item): return item != client)
		var req_as_str = client.get_string(bytes)
		if req_as_str.length() < 1:
			continue

		var req_info = req_as_str.split('\n')[0].split(' ')
		var method = req_info[0]
		var url = req_info[1]

		match method:
			'GET':
				send200(client, get_login_page())
			'POST':
				var token = URL.new(url).query.token
				if !token: return
				token_received.emit(token)
				send200(client)


func send200(client: StreamPeer, data: String = ''):
	var data_buffer = data.to_ascii_buffer()
	client.put_data(('HTTP/1.1 200 OK\r\n').to_ascii_buffer())
	client.put_data(('Server: AUTH_SERVER\r\n').to_ascii_buffer())
	client.put_data(('Content-Length: %d\r\n' % data_buffer.size()).to_ascii_buffer())
	client.put_data(('Connection: close\r\n').to_ascii_buffer())
	client.put_data(('Content-Type: text/html\r\n').to_ascii_buffer())
	client.put_data(('\r\n').to_ascii_buffer())
	client.put_data(data_buffer)


func get_login_page() -> String:
	var path = Yatc.singleton.get_module_path().path_join('public/index.html')
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return content
