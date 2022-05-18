extends Node

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal input_bounced(event)
signal view_mode_changed(mode)
signal active_joypad_changed(device, device_name)


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
export var active_joypad_id : int = 0					setget set_active_joypad_id

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

func set_active_joypad_id(idx : int) -> void:
	if Input.get_joy_name(idx) != "":
		active_joypad_id = idx
		_UpdateJoypadActions()
		emit_signal("active_joypad_changed", active_joypad_id, Input.get_joy_name(active_joypad_id))
		

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	set_joypad_to_first_identified()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _UpdateJoypadActions() -> void:
	var actions : Array = InputMap.get_actions()
	for action in actions:
		var ielist : Array = InputMap.get_action_list(action)
		for ie in ielist:
			if ie is InputEventJoypadButton:
				#print ("Joypad Button discovered for action: ", action)
				ie.device = active_joypad_id


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func bounce_input(event) -> void:
	emit_signal("input_bounced", event)

func get_joypad_list() -> Array:
	var joys : Array = []
	var conjoy : Array = Input.get_connected_joypads()
	for did in conjoy:
		joys.append({
			"id": did,
			"name": Input.get_joy_name(did)
		})
	return joys

func set_joypad_to_first_identified() -> bool:
	var conjoy : Array = Input.get_connected_joypads()
	if conjoy.size() > 0:
		set_active_joypad_id(conjoy[0])
		return true
	return false

func get_action_description(action_name : String) -> String:
	for a in _INPUT_ACTION_DEF:
		if a.action_name == action_name:
			return a.description
	return ""

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
