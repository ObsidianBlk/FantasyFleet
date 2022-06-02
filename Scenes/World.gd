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
	call_deferred("_KickPig")

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		print("Cancel call")
		if get_tree().paused:
			get_tree().paused = false
			emit_signal("ui_requested", "")
		else:
			get_tree().quit()
	elif event.is_action_pressed("option_toggle"):
		get_tree().paused = not get_tree().paused # TODO: Figure out a better way to pause
		emit_signal("ui_toggle_requested", "Options")

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _KickPig() -> void:
	var hmd : HexMapData = HexMapData.new()
	hmd.cell_size = 60.0
	HexMap.hex_map_data = hmd
	
#	var pl = ProjectSettings.get_property_list()
#	for p in pl:
#		if p.name.begins_with("input/"):
#			print(p.name)
	print(ProjectSettings.get_setting("input/ui_up").events[0].get_class())

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_GameScreen_resized():
	if _view2d_node:
		_view2d_node.size = OS.window_size
	if _view3d_node:
		_view3d_node.size = OS.window_size
