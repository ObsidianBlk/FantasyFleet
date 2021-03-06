extends Node

# https://godotengine.org/qa/64801/sending-variable-data-from-server-to-a-client

# -----------------------------------------------------------------------------
# Signals
# -----------------------------------------------------------------------------
signal network_initialized()
signal network_disconnected()
signal network_init_failed()


# -----------------------------------------------------------------------------
# Constant
# -----------------------------------------------------------------------------
const MIN_PORT : int = 1024
const DEFAULT_PORT : int = 20226

enum NET_SIG_MODE {Server=0, Client=1, Both=2}
const NET_SIGNALS : Array = [
	{
		signal_name = "network_peer_connected",
		method_name = "_on_network_peer_connected",
		mode = NET_SIG_MODE.Both
	},
	{
		signal_name = "network_peer_disconnected",
		method_name = "_on_network_peer_disconnected",
		mode = NET_SIG_MODE.Both
	},
	{
		signal_name = "connected_to_server",
		method_name = "_on_connected_to_server",
		mode = NET_SIG_MODE.Client
	},
	{
		signal_name = "connection_failed",
		method_name = "_on_connection_failed",
		mode = NET_SIG_MODE.Client
	},
	{
		signal_name = "server_disconnected",
		method_name = "_on_server_disconnected",
		mode = NET_SIG_MODE.Client
	}
]

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
var _id : int = 0
var _pid : Dictionary = {}

# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	pass


# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------
func _PostNetworkInit(mode : int = -1) -> void:
	var st : SceneTree = get_tree()
	_id = st.get_network_unique_id()
	for conn in NET_SIGNALS:
		if conn.mode == mode or conn.mode == NET_SIG_MODE.Both:
			if not st.is_connected(conn.signal_name, self, conn.method_name):
				st.connect(conn.signal_name, self, conn.method_name)

# -----------------------------------------------------------------------------
# Public Methods
# -----------------------------------------------------------------------------
func join_game(address : String, port : int = -1) -> int:
	var st : SceneTree = get_tree()
	if st.has_network_peer():
		Log.error("Network already connected.")
		#printerr("Network already connected.")
		emit_signal("network_init_failed", ERR_ALREADY_IN_USE)
		return ERR_ALREADY_IN_USE
	
	if port < MIN_PORT:
		port = DEFAULT_PORT
	
	var peer : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	var res : int = peer.create_client(address, port)
	if res == OK:
		st.network_peer = peer
		_PostNetworkInit(NET_SIG_MODE.Client)
		emit_signal("network_initialized")
	else:
		emit_signal("network_init_failed", res)
	
	return res


func host_game(max_players : int = 2, port : int = -1) -> int:
	var st : SceneTree = get_tree()
	if st.has_network_peer():
		Log.error("Network already connected.")
		#printerr("Network already connected.")
		emit_signal("network_init_failed", ERR_ALREADY_IN_USE)
		return ERR_ALREADY_IN_USE
	
	if port < MIN_PORT:
		port = DEFAULT_PORT
	if max_players < 2:
		max_players = 2
	
	var peer : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	var res : int = peer.create_server(port, max_players - 1)
	if res == OK:
		st.network_peer = peer
		_PostNetworkInit(NET_SIG_MODE.Server)
		emit_signal("network_initialized")
	else:
		emit_signal("network_init_failed", res)
	return res


func disconnect_game(unregister : bool = true) -> int:
	var st : SceneTree = get_tree()
	if not st.has_network_peer():
		return ERR_DOES_NOT_EXIST
	if unregister:
		rpc("r_unregister_player_profile")
	st.network_peer = null
	emit_signal("network_disconnected")
	return OK

func send_data(data, to_id : int = -1) -> void:
	var self_id : int = get_tree().get_network_unique_id()
	if self_id == 1:
		if to_id > 1:
			rpc_id(to_id, "r_receive_data", data)
		else:
			rpc("r_receive_data", data)
	else:
		rpc_id(1, "r_receive_data", data, to_id)

# -----------------------------------------------------------------------------
# Remote Methods
# -----------------------------------------------------------------------------
remote func r_register_player_profile(profile : Dictionary) -> void:
	var id : int = get_tree().get_rpc_sender_id()
	# TODO: Varify dictionary data
	_pid[id] = profile
	Log.info("Registered client: %d - %s"%[id, profile])
	#print("Registered client: ", id, " - ", profile)

remote func r_unregister_player_profile() -> void:
	var id : int = get_tree().get_rpc_sender_id()
	print(_pid)
	if id in _pid:
		_pid.erase(id)
		Log.info("Unregistered client: %d"%[id])
		#print("Unregistered client: ", id)

remote func r_receive_data(data, to_id : int = -1) -> void:
	var id : int = get_tree().get_rpc_sender_id()
	if id == 1 and to_id > 1:
		rpc_id(to_id, "r_receive_data", data)
	else:
		Log.debug("Obtained data from %d"%[id])
		# TODO: Process data for command

# -----------------------------------------------------------------------------
# Handler Methods
# -----------------------------------------------------------------------------
func _on_network_peer_connected(id : int) -> void:
	if id in _pid:
		Log.warning("Client ID %d already exists."%[id])
		#printerr("WARNING: Client ID ", id, " already exists.")
	Log.info("New client connected, %d"%[id])
	var sid : int = get_tree().get_network_unique_id()
	if sid == 1:
		Log.debug("Sending data to client %d"%[id])
		send_data("Hello from server", id)
	#_pid[id] = {"name":"Unknown"} # This is temporary!

func _on_network_peer_disconnected(id : int) -> void:
	if id != get_tree().get_network_unique_id():
		if id in _pid:
			_pid.erase(id)
		Log.info("Client disconnected: %d"%[id])
		#print("Client disconnected: ", id)

func _on_connected_to_server() -> void:
	var id : int = get_tree().get_network_unique_id()
	if id != 1:
		rpc("r_register_player_profile", Game.get_profile())
	else:
		_pid[id] = Game.get_profile()

func _on_connection_failed() -> void:
	Log.info("Failed to connect to the server")
	#print("Failed to connect to the server")
	call_deferred("disconnect_game", false)

func _on_server_disconnected() -> void:
	Log.info("Server disconnected")
	#print("Server disconnected")
	call_deferred("disconnect_game", false)

