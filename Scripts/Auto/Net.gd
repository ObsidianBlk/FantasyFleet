extends Node

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
		printerr("Network already connected.")
		return ERR_ALREADY_IN_USE
	
	if port < MIN_PORT:
		port = DEFAULT_PORT
	
	var peer : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	var res : int = peer.create_client(address, port)
	if res == OK:
		st.network_peer = peer
		_PostNetworkInit(NET_SIG_MODE.Client)
	
	return res


func host_game(max_players : int = 2, port : int = -1) -> int:
	var st : SceneTree = get_tree()
	if st.has_network_peer():
		printerr("Network already connected.")
		return ERR_ALREADY_IN_USE
	
	if port < MIN_PORT:
		port = DEFAULT_PORT
	if max_players < 2:
		max_players = 2
	
	var peer : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
	var res : int = peer.create_server(port, max_players)
	if res == OK:
		st.network_peer = peer
		_PostNetworkInit(NET_SIG_MODE.Server)
	
	return res


func disconnect_game() -> int:
	var st : SceneTree = get_tree()
	if not st.has_network_peer():
		return ERR_DOES_NOT_EXIST
	
	
	return OK

# -----------------------------------------------------------------------------
# Remote Methods
# -----------------------------------------------------------------------------
remote func r_get_info() -> Dictionary:
	
	return {}

# -----------------------------------------------------------------------------
# Handler Methods
# -----------------------------------------------------------------------------
func _on_network_peer_connected(id : int) -> void:
	if id in _pid:
		printerr("WARNING: Client ID ", id, " already exists.")
	_pid[id] = {"name":"Unknown"} # This is temporary!

func _on_network_peer_disconnected(id : int) -> void:
	print("Lost Peer: ", id)

func _on_connected_to_server() -> void:
	print("I connected to the server!")

func _on_connection_failed() -> void:
	print("Failed to connect to the server")

func _on_server_disconnected() -> void:
	print("Server abandoned me!")

