tool
extends Node

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal eim_initialized(project_name)
signal eim_deactivated()

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
# EPS = Extended Project Settings. May create this direct plugin later,
#   but I want to precreate this acronym.
const SETTINGS_NAME_VAR : String = "application/config/eps_name"

# ---
# SUBPROP_* - A grouping for properties, but not a direct property value.
const SUBPROP_EI_GROUPS : String = "/ei_groups/"

# ---
# PROP_* - A direct property value path.
const PROP_EI_GROUP_LIST : String = "/ei_groups_list"


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _project_name : String = ""

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	if not Engine.editor_hint:
		# We need to kick this pig
		initialize()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _GetGroupData(key : String, basic_validation : bool = false): # Returns Null, Dictionary, or String
	# Since Projects Settings can, technically, be edited via a text editor
	# there lacks trust that the values will be as expected. As such,
	# verification of the data (if there is any for the given key) is required
	# to maintain as much consistency as possible.
	if ProjectSettings.has_setting(key):
		var data = ProjectSettings.get_setting(key)
		if typeof(data) != TYPE_DICTIONARY:
			return "Setting \"%s\" is an invalid type."%[key]
		if basic_validation:
			return data
		
		var iprops : Dictionary = {
			"unique_inputs":TYPE_BOOL,
			"actions":TYPE_ARRAY,
		}
		for prop in iprops.keys():
			if not prop in data:
				return "Setting \"%s\" dictionary missing required property \"%s\"."%[key, prop]
			if typeof(data[prop]) != iprops[prop]:
				return "Setting \"%s\" dictionary property \"%s\" invalid type."%[key, prop]
		return data
	return null


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func initialize() -> bool:
	if ProjectSettings.has_setting(SETTINGS_NAME_VAR):
		var project_name = ProjectSettings.get_setting(SETTINGS_NAME_VAR)
		if project_name == _project_name and _project_name != "":
			return true # We've already verified initialization. Nothing really do to
		
		var init : bool = true
		if typeof(project_name) != TYPE_STRING:
			printerr("EIM ERROR: Setting \"", SETTINGS_NAME_VAR, "\" invalid type.")
			init = false
		if init == true and not project_name.is_valid_identifier():
			printerr("EIM ERROR: Setting \"", SETTINGS_NAME_VAR, "\" not a valid identifier.")
			init = false
		if init:
			_project_name = project_name
			emit_signal("eim_initialized", _project_name)
			return true
	
	if _project_name != "":
		_project_name = ""
		emit_signal("eim_deactivated")
	return false

func get_project_name() -> String:
	return _project_name

func get_group_list() -> Array:
	if _project_name == "":
		return []
	
	if not ProjectSettings.has_setting(_project_name + PROP_EI_GROUP_LIST):
		return []
	var glist = ProjectSettings.get_setting(_project_name + PROP_EI_GROUP_LIST)
	if typeof(glist) != TYPE_ARRAY:
		return []
	return glist


func set_group(group_name : String, unique_inputs : bool = true, preserv_actions : bool = false) -> bool:
	if _project_name == "":
		return false
	
	if not group_name.is_valid_identifier():
		printerr("EIM ERROR: Extended Input Group Name identifier, \"", group_name, "\" invalid.")
		return false
	
	var glist : Array = get_group_list()
	
	var key = _project_name + SUBPROP_EI_GROUPS + group_name
	var data = _GetGroupData(key)
	if typeof(data) == TYPE_STRING:
		printerr("EIM ERROR: ", data)
		return false
	elif typeof(data) == TYPE_DICTIONARY:
		data.unique_inputs = unique_inputs
		if not preserv_actions:
			data.actions = []
	else:
		data = {"unique_inputs":unique_inputs, "actions":[]}

	ProjectSettings.set_setting(key, data)
	if glist.find(group_name) < 0:
		glist.append(group_name)
		ProjectSettings.set_setting(_project_name + PROP_EI_GROUP_LIST, glist)
	return true


func drop_group(group_name : String) -> void:
	if _project_name == "" or not group_name.is_valid_identifier():
		return
	var key = _project_name + SUBPROP_EI_GROUPS + group_name
	if ProjectSettings.has_setting(key):
		var glist : Array = get_group_list()
		var idx : int = glist.find(group_name)
		if idx < 0:
			printerr("EIM ERROR: Extended input group \"", group_name, "\" found, but not listed.")
			return
		glist.remove(idx)
		ProjectSettings.set_setting(key, null)
		ProjectSettings.set_setting(_project_name + PROP_EI_GROUP_LIST, glist)


func has_group(group_name : String) -> bool:
	if _project_name != "" and group_name.is_valid_identifier():
		var key = _project_name + SUBPROP_EI_GROUPS + group_name
		return ProjectSettings.has_setting(key)
	return false

func get_group_action_list(group_name : String) -> Array:
	if _project_name != "" and group_name.is_valid_identifier():
		var key = _project_name + SUBPROP_EI_GROUPS + group_name
		var data = _GetGroupData(key)
		if typeof(data) == TYPE_STRING:
			printerr("EIM ERROR: ", data)
		elif typeof(data) == TYPE_DICTIONARY:
			return data.actions.duplicate()
	return []

func add_action_to_group(group_name : String, action_name : String) -> bool:
	if _project_name == "":
		return false
	
	if not group_name.is_valid_identifier():
		printerr("EIM ERROR: Extended Input Group Name identifier, \"", group_name, "\" invalid.")
		return false
	
	if not ProjectSettings.has_setting(action_name):
		return false
	
	var action = ProjectSettings.get_setting(action_name)
	if typeof(action) != TYPE_DICTIONARY:
		return false
	if not "deadzone" in action:
		return false
	if not "events" in action:
		return false
	
	
	var key = _project_name + SUBPROP_EI_GROUPS + group_name
	if not ProjectSettings.has_setting(key):
		return false
	
	var glist = get_group_list()
	var res : bool = false
	for gname in glist:
		if typeof(gname) != TYPE_STRING or not gname.is_valid_identifier():
			continue
		var gkey : String = _project_name + SUBPROP_EI_GROUPS + gname
		var data = _GetGroupData(gkey, true)
		if typeof(data) == TYPE_STRING:
			printerr("EIM ERROR: ", data)
		elif typeof(data) == TYPE_DICTIONARY:
			if gkey == key: # Add it if this is the target group
				if data.actions.find(action_name) < 0:
					data.actions.append(action_name)
					ProjectSettings.set_setting(key, data)
				res = true
			else: # Remove it if this is NOT the target group
				var idx : int = data.actions.find(action_name)
				if idx >= 0:
					data.actions.remove(idx)
					ProjectSettings.set_settings(gkey, data)
	return res


func is_action_in_group(group_name : String, action_name : String) -> bool:
	if _project_name != "" and group_name.is_valid_identifier():
		var key = _project_name + SUBPROP_EI_GROUPS + group_name
		var data = _GetGroupData(key)
		if typeof(data) == TYPE_STRING:
			printerr("EIM ERROR: ", data)
		elif typeof(data) == TYPE_DICTIONARY:
			return data.actions.find(action_name) >= 0
	return false

func is_action_assigned_group(action_name : String) -> bool:
	if _project_name == "":
		return false
	
	var glist = get_group_list()
	for group_name in glist:
		if is_action_in_group(group_name, action_name):
			return true
	return false

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

