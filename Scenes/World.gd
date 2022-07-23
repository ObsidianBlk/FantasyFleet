extends Node2D


# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal ui_requested(ui_name)
signal ui_toggle_requested(ui_name)

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------

onready var _view3d_node : Viewport = $Viewport3D
onready var _view2d_node : Viewport = $Viewport2D


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_on_GameScreen_resized()
	
	Game.connect("game_config_loaded", EIM, "load_from_config")
	Game.connect("game_config_saving", EIM, "save_to_config")
	
	Game.config_load()
	var prof_name : String = Utils.uuidv4()
	Game.create_profile(prof_name)
	Game.select_profile(prof_name)
	call_deferred("_KickPig")

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			emit_signal("ui_requested", "")
		else:
			Game.config_save()
			get_tree().quit()
	elif event.is_action_pressed("network_toggle"):
		get_tree().paused = not get_tree().paused
		emit_signal("ui_toggle_requested", "Network")
	elif event.is_action_pressed("option_toggle"):
		get_tree().paused = not get_tree().paused # TODO: Figure out a better way to pause
		emit_signal("ui_toggle_requested", "Options")
	elif event.is_action_pressed("term_toggle"):
		emit_signal("ui_toggle_requested", "Terminal")

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _KickPig() -> void:
	var hmd : HexMapData = HexMapData.new()
	hmd.cell_size = 60.0
	HexMap.hex_map_data = hmd
	
	var origin : HexCell = HexCell.new()
	HexMap.add_area_region(origin.get_neighbor(2, 10), 2)
	HexMap.add_ring_region(origin.get_neighbor(4, 20), 12)
	HexMap.add_line_region(origin, origin.get_neighbor(4, 12).get_neighbor(3, 8))
	
#	var pl = ProjectSettings.get_property_list()
#	for p in pl:
#		if p.name.begins_with("input/"):
#			print(p.name)
	#print(ProjectSettings.get_setting("input/ui_up").events[0].get_class())

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_GameScreen_resized():
	if _view2d_node:
		_view2d_node.size = OS.window_size
	if _view3d_node:
		_view3d_node.size = OS.window_size


func _on_Network_host_requested(port : int, max_players : int):
	get_tree().paused = false
	if Net.host_game(max_players, port) == OK:
		Log.info("Network server started successfully")
	else:
		Log.warning("Failed to start network server.")

func _on_Network_join_requested(address : String, port : int):
	get_tree().paused = false
	if Net.join_game(address, port) == OK:
		Log.info("Attempted to join server %s:%d ... "%[address, port])
	else:
		Log.warning("Failed start network service to %s:%d"%[address, port])

func _on_Network_disconnect_network_requested():
	get_tree().paused = false
	Net.disconnect_game()
