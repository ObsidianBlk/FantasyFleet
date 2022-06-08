extends Node

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal input_bounced(event)
signal view_mode_changed(mode)


# -------------------------------------------------------------------------
# Constants and ENUMs
# -------------------------------------------------------------------------
const _INPUT_ACTION_DEF = [
	{action_name="game_up", description="Move Map Up"},
	{action_name="game_down", description="Move Map Down"},
	{action_name="game_left", description="Move Map Left"},
	{action_name="game_right", description="Move Map Right"},
	{action_name="game_shift", description="Toggle Something"},
	{action_name="game_ctrl", description="Toggle Something Else"},
	{action_name="game_view_toggle", description="Toggle 2D/3D View"}
]

enum VIEW {MODE_2D=0, MODE_3D=1}

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export (VIEW) var view_mode : int = VIEW.MODE_2D		setget set_view_mode

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_view_mode(vm : int) -> void:
	if VIEW.values().find(vm) >= 0:
		view_mode = vm
		emit_signal("view_mode_changed", view_mode)

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	pass

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------



# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func bounce_input(event) -> void:
	emit_signal("input_bounced", event)


func get_action_description(action_name : String) -> String:
	for a in _INPUT_ACTION_DEF:
		if a.action_name == action_name:
			return a.description
	return ""

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
