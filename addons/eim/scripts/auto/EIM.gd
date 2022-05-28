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

func _FindDataAction(data : Dictionary, action_name : String) -> int:
	for i in range(0, data.actions.size()):
		if data.actions[i].name == action_name:
			return i
	return -1

func _IsValidAction(act) -> bool:
	return typeof(act) == TYPE_DICTIONARY and "events" in act

func _AreActionsUnique(action1_name : String, action2_name : String) -> bool:
	var action1 = ProjectSettings.get_setting(action1_name)
	if _IsValidAction(action1):
		return false
	var action2 = ProjectSettings.get_setting(action2_name)
	if _IsValidAction(action2):
		return false
	for a1e in action1.events:
		for a2e in action2.events:
			if a1e.get_class() == a2e.get_class():
				match a1e.get_class():
					"InputEventKey":
						if a1e.scancode == a2e.scancode and a1e.physical_scancode == a2e.physical_scancode:
							return false
					"InputEventMouseButton":
						if a1e.button_index == a2e.button_index:
							return false
					"InputEventJoypadMotion":
						if a1e.axis == a2e.axis:
							return false
					"InputEventJoypadButton":
						if a1e.button_index == a2e.button_index:
							return false
				return true
	return false

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
	return glist.duplicate()


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


func set_group_inputs_unique(group_name : String, unique : bool = true) -> void:
	if _project_name != "" and group_name.is_valid_identifier():
		var key = _project_name + SUBPROP_EI_GROUPS + group_name
		var data = _GetGroupData(key, true)
		if typeof(data) == TYPE_DICTIONARY:
			if data.unique_inputs != unique:
				data.unique_inputs = unique
				ProjectSettings.set_setting(key, data)
		else:
			printerr("EIM ERROR: ", data)


func are_group_inputs_unique(group_name : String) -> bool:
	if _project_name != "" and group_name.is_valid_identifier():
		var key = _project_name + SUBPROP_EI_GROUPS + group_name
		var data = _GetGroupData(key, true)
		if typeof(data) == TYPE_DICTIONARY:
			return data.unique_inputs
		printerr("EIM ERROR: ", data)
	return false


func get_group_action_list(group_name : String) -> Array:
	var adlist : Array = []
	if _project_name != "" and group_name.is_valid_identifier():
		var key = _project_name + SUBPROP_EI_GROUPS + group_name
		var data = _GetGroupData(key)
		if typeof(data) == TYPE_STRING:
			printerr("EIM ERROR: ", data)
		elif typeof(data) == TYPE_DICTIONARY:
			for adat in data.actions:
				adlist.append({"name":adat.name, "desc":adat.desc})
	return adlist

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
	var data = _GetGroupData(key, true)
	if typeof(data) == TYPE_STRING:
		printerr("EIM ERROR: ", data)
		return false
	
	var glist = get_group_list()
	var desc : String = ""
	for gname in glist:
		if typeof(gname) != TYPE_STRING or not gname.is_valid_identifier():
			continue
		var gkey : String = _project_name + SUBPROP_EI_GROUPS + gname
		var gdata = _GetGroupData(gkey, true)
		if typeof(data) == TYPE_STRING:
			printerr("EIM ERROR: ", data)
		elif typeof(data) == TYPE_DICTIONARY:
			if gkey != key: # If not group check to see if action exists
				var idx : int = data.actions.find(action_name)
				if idx >= 0:
					desc = data.actions[idx].desc
					data.actions.remove(idx)
					ProjectSettings.set_settings(gkey, data)
	
	
	var idx = _FindDataAction(data, action_name)
	if idx < 0:
		data.actions.append({"name": action_name, "desc":desc})
	else:
		data.actions[idx].desc = desc
	ProjectSettings.set_setting(key, data)
	
	return true


func drop_action_from_group(group_name : String, action_name : String) -> void:
	if _project_name == "":
		return
	if not group_name.is_valid_identifier():
		printerr("EIM ERROR: Extended Input Group Name identifier, \"", group_name, "\" invalid.")
		return
	var key = _project_name + SUBPROP_EI_GROUPS + group_name
	var data = _GetGroupData(key, true)
	if typeof(data) == TYPE_STRING:
		printerr("EIM ERROR: ", data)
	var idx : int = _FindDataAction(data, action_name)
	if idx >= 0:
		data.actions.remove(idx)
		ProjectSettings.set_setting(key, data)


func set_group_action_description(group_name : String, action_name : String, description : String) -> void:
	if _project_name == "":
		return
	if not group_name.is_valid_identifier():
		printerr("EIM ERROR: Extended Input Group Name identifier, \"", group_name, "\" invalid.")
		return
	var key = _project_name + SUBPROP_EI_GROUPS + group_name
	var data = _GetGroupData(key, true)
	if typeof(data) == TYPE_STRING:
		printerr("EIM ERROR: ", data)
	var idx : int = _FindDataAction(data, action_name)
	if idx >= 0:
		data.actions[idx].desc = description
		ProjectSettings.set_setting(key, data)


func replace_group_action_input(group_name : String, action_name : String, old_input : InputEvent, new_input : InputEvent) -> void:
	if not is_action_in_group(group_name, action_name):
		printerr("EIM ERROR: Action \"", action_name, "\" not assigned group \"", group_name, "\". Ignoring due to possible conflict with ungrouped input(s).")
		return
	if old_input.get_class() != new_input.get_class():
		printerr("EIM ERROR: Old input event not same type as new input event.")
		return # Only replace inputs of the same type
	var action = ProjectSettings.get_setting(action_name)
	if not (typeof(action) == TYPE_DICTIONARY and "events" in action):
		printerr("EIM ERROR: Action \"", action_name, "\" missing or invalid.")
	for event in action.events:
		var event_class : String = event.get_class()
		if event.get_class() == old_input.get_class():
			match event.get_class():
				"InputEventKey":
					if event.scancode == old_input.scancode and event.physical_scancode == old_input.physical_scancode:
						event.scancode = new_input.scancode
						event.physical_scancode = new_input.physical_scancode
				"InputEventMouseButton":
					if event.button_index == old_input.button_index:
						event.button_index = new_input.button_index
				"InputEventJoypadMotion":
					if event.axis == old_input.axis:
						event.axis = new_input.axis
				"InputEventJoypadButton":
					if event.button_index == old_input.button_index:
						event.button_index = new_input.button_index
			# NOTE: I'm going to assume, at the moment, that the event values will
			#   modify in place


func is_group_action_inputs_unique(group_name : String, action_name : String) -> bool:
	if not is_action_in_group(group_name, action_name):
		return false
	var alist = get_group_action_list(group_name)
	if alist.size() > 0:
		for adata in alist:
			if adata.name != action_name:
				if not _AreActionsUnique(action_name, adata.name):
					return false
	return true


func is_group_actions_unique(group_name : String) -> bool:
	var alist = get_group_action_list(group_name)
	if alist.size() > 0:
		for a1idx in range(alist.size() - 1):
			for a2idx in range(a1idx + 1, alist.size()):
				if not _AreActionsUnique(alist[a1idx].name, alist[a2idx].name):
					return false
	return true


func is_action_in_group(group_name : String, action_name : String) -> bool:
	if _project_name != "" and group_name.is_valid_identifier():
		var key = _project_name + SUBPROP_EI_GROUPS + group_name
		var data = _GetGroupData(key)
		if typeof(data) == TYPE_STRING:
			printerr("EIM ERROR: ", data)
		elif typeof(data) == TYPE_DICTIONARY:
			return _FindDataAction(data, action_name) >= 0
	return false

func is_action_assigned_group(action_name : String) -> bool:
	if _project_name == "":
		return false
	
	var glist = get_group_list()
	for group_name in glist:
		if is_action_in_group(group_name, action_name):
			return true
	return false

func action_has_key_inputs(action_name : String) -> bool:
	var action = ProjectSettings.get_setting(action_name)
	if typeof(action) == TYPE_DICTIONARY:
		if "events" in action:
			for event in action.events:
				if event is InputEventKey:
					return true
	return false

func action_has_mouse_inputs(action_name : String) -> bool:
	var action = ProjectSettings.get_setting(action_name)
	if typeof(action) == TYPE_DICTIONARY:
		if "events" in action:
			for event in action.events:
				if event is InputEventMouseButton:
					return true
	return false

func action_has_joypad_button_inputs(action_name : String) -> bool:
	var action = ProjectSettings.get_setting(action_name)
	if typeof(action) == TYPE_DICTIONARY:
		if "events" in action:
			for event in action.events:
				if event is InputEventJoypadButton:
					return true
	return false

func action_has_joypad_axii_inputs(action_name : String) -> bool:
	var action = ProjectSettings.get_setting(action_name)
	if typeof(action) == TYPE_DICTIONARY:
		if "events" in action:
			for event in action.events:
				if event is InputEventJoypadMotion:
					return true
	return false

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

