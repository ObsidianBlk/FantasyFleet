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
		get_tree().quit()
	elif event is InputEventKey:
		if event.physical_scancode == KEY_O and event.is_pressed() and not event.is_echo():
			emit_signal("ui_toggle_requested", "Options")

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _KickPig() -> void:
	var hmd : HexMapData = HexMapData.new()
	hmd.cell_size = 60.0
	HexMap.hex_map_data = hmd
	
	#print(ProjectSettings.get_setting("input/ui_up"))

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_GameScreen_resized():
	if _view2d_node:
		_view2d_node.size = OS.window_size
	if _view3d_node:
		_view3d_node.size = OS.window_size
