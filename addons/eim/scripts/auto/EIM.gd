tool
extends Node

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal initialized(project_name)
signal deconstructed()
signal active_joypad_changed(device, device_name)

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
# EPS = Extended Project Settings. May create this direct plugin later,
#   but I want to precreate this acronym.
const SETTINGS_SECTION_VAR : String = "application/config/eim_project_section"
const SETTINGS_CONF_SECTION_VAR : String = "application/config/eim_config_section"

# ---
# SUBPROP_* - A grouping for properties, but not a direct property value.
const SUBPROP_EI_GROUPS : String = "/ei_groups/"
const SUBPROP_INPUT : String = "input/"

# ---
# PROP_* - A direct property value path.
const PROP_EI_GROUP_LIST : String = "/ei_groups_list"

const DEFAULT_ACTIONS : PoolStringArray = PoolStringArray([
	"ui_accept",
	"ui_cancel",
	"ui_down",
	"ui_end",
	"ui_focus_next",
	"ui_focus_prev",
	"ui_home",
	"ui_left",
	"ui_page_down",
	"ui_page_up",
	"ui_right",
	"ui_select",
	"ui_up"
])

const CONFIG_DEFAULT_SECTION_NAME : String = "Input"


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _active_joypad_id : int = 0
var _favored_joypad_name : String = ""

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _FindDataAction(data : Dictionary, action_name : String) -> int:
	for i in range(0, data.actions.size()):
		if data.actions[i].name == action_name:
			return i
	return -1

func _IEKScancode(e : InputEventKey) -> int:
	if e.scancode > 0:
		return e.scancode
	elif e.physical_scancode > 0:
		var code_string = OS.get_scancode_string(e.physical_scancode)
		return OS.find_scancode_from_string(code_string)
	return -1

func _AreEventsUnique(ae1, ae2) -> int:
	if ae1.get_class() == ae2.get_class():
		match ae1.get_class():
			"InputEventKey":
				if _IEKScancode(ae1) == _IEKScancode(ae2):
					return FAILED
			"InputEventMouseButton":
				if ae1.button_index == ae2.button_index:
					return FAILED
			"InputEventJoypadMotion":
				if ae1.axis == ae2.axis:
					return FAILED
			"InputEventJoypadButton":
				if ae1.button_index == ae2.button_index:
					return FAILED
		return OK
	return ERR_INVALID_DATA

func _AreActionsUniqueEditorMode(action_name1 : String, action_name2 : String) -> bool:
	var a1key : String = "%s%s"%[SUBPROP_INPUT, action_name1]
	var a2key : String = "%s%s"%[SUBPROP_INPUT, action_name2]
	if ProjectSettings.has_setting(a1key) and ProjectSettings.has_setting(a2key):
		var action1 = ProjectSettings.get_setting(a1key)
		var action2 = ProjectSettings.get_setting(a2key)
		if not action1 or not action2:
			return false
		
		for ae1 in action1.events:
			for ae2 in action2.events:
				var res : int = _AreEventsUnique(ae1, ae2)
				if res == FAILED:
					return false
		return true
	return false


func _AreActionsUnique(action_name1 : String, action_name2 : String) -> bool:
	if InputMap.has_action(action_name1) and InputMap.has_action(action_name2):
		for ae1 in InputMap.get_action_list(action_name1):
			for ae2 in InputMap.get_action_list(action_name2):
				var res : int = _AreEventsUnique(ae1, ae2)
				if res == FAILED:
					return false
		return true
	return false

func _GetProjectSettingsAction(action_name : String):
	if not action_name.begins_with(SUBPROP_INPUT):
		action_name = SUBPROP_INPUT + action_name
	if ProjectSettings.has_setting(action_name):
		var action = ProjectSettings.get_setting(action_name)
		if typeof(action) == TYPE_DICTIONARY:
			return action
	return null


func _UpdateJoypadActions() -> void:
	var actions : Array = InputMap.get_actions()
	for action in actions:
		var ielist : Array = InputMap.get_action_list(action)
		for ie in ielist:
			if ie is InputEventJoypadButton:
				ie.device = _active_joypad_id

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func initialize_eim(project_name : String, initialize_default_inputs : bool) -> int:
	if not Engine.editor_hint:
		return FAILED
	if not project_name.is_valid_identifier():
		return ERR_INVALID_DECLARATION
	
	if ProjectSettings.has_setting(SETTINGS_SECTION_VAR):
		var proj = ProjectSettings.get_setting(SETTINGS_SECTION_VAR)
		if project_name != proj:
			printerr("EIM Initilization failed. Required setting \"", SETTINGS_SECTION_VAR, "\" already exists.")
			return ERR_DUPLICATE_SYMBOL
	if ProjectSettings.has_setting(SETTINGS_CONF_SECTION_VAR):
		printerr("EIM Initilization failed. Required setting \"", SETTINGS_CONF_SECTION_VAR, "\" already exists.")
		return ERR_DUPLICATE_SYMBOL
	else:
		ProjectSettings.set_setting(SETTINGS_SECTION_VAR, project_name)
		ProjectSettings.set_setting(SETTINGS_CONF_SECTION_VAR, CONFIG_DEFAULT_SECTION_NAME)
		ProjectSettings.set_setting(project_name + PROP_EI_GROUP_LIST, [])
		if initialize_default_inputs:
			if set_group("ui_actions", false):
				for action_name in DEFAULT_ACTIONS:
					add_action_to_group("ui_actions", action_name)
		var res : int = ProjectSettings.save()
		if res != OK:
			deconstruct_eim()
			return res
		emit_signal("initialized", project_name)
	return OK

func deconstruct_eim() -> int:
	if not Engine.editor_hint:
		return FAILED
	var project_name : String = get_project_name()
	if project_name == "":
		return ERR_UNCONFIGURED
	
	var glist = get_group_list()
	for group_name in glist:
		drop_group(group_name)
	ProjectSettings.set_setting(project_name + PROP_EI_GROUP_LIST, null)
	ProjectSettings.set_setting(SETTINGS_CONF_SECTION_VAR, null)
	ProjectSettings.set_setting(SETTINGS_SECTION_VAR, null)
	ProjectSettings.save()
	emit_signal("deconstructed")
	
	return OK


func load_from_config(conf : ConfigFile) -> void:
	var section : String = get_config_section()
	if section == "":
		return
	
	if not conf.has_section(section):
		return
	
	if conf.has_section_key(section, "favored_joypad_name"):
		_favored_joypad_name = conf.get_value(section, "favored_joypad_name", "")
	
	var group_list : Array = get_group_list()
	for group_name in group_list:
		var action_list : Array = get_group_action_list(group_name)
		for action_data in action_list:
			if InputMap.has_action(action_data.name):
				InputMap.action_erase_events(action_data.name)
			else:
				printerr("WARNING: InputMap missing action \"", action_data.name, "\" event definition.")
				InputMap.add_action(action_data.name)
			var key_base = "%s.%s"%[group_name, action_data.name]
			if conf.has_section_key(section, "%s.scancode"%[key_base]):
				var scancode : int = conf.get_value(section, "%s.scancode"%[key_base], 0)
				if scancode > 0:
					var event : InputEventKey = InputEventKey.new()
					event.scancode = scancode
					InputMap.action_add_event(action_data.name, event)
			if conf.has_section_key(section, "%s.mouse_button"%[key_base]):
				var id : int = conf.get_value(section, "%s.mouse_button"%[key_base], -1)
				if id >= 0:
					var event : InputEventMouseButton = InputEventMouseButton.new()
					event.button_index = id
					InputMap.action_add_event(action_data.name, event)
			if conf.has_section_key(section, "%s.joy_axis"%[key_base]):
				var id : int = conf.get_value(section, "%s.joy_axis"%[key_base], -1)
				if id >= 0:
					var event : InputEventJoypadMotion = InputEventJoypadMotion.new()
					event.axis = id
					InputMap.action_add_event(action_data.name, event)
			if conf.has_section_key(section, "%s.joy_button"%[key_base]):
				var id : int = conf.get_value(section, "%s.joy_button"%[key_base], -1)
				if id >= 0:
					var event : InputEventJoypadButton = InputEventJoypadButton.new()
					event.button_index = id
					InputMap.action_add_event(action_data.name, event)



func save_to_config(conf : ConfigFile) -> void:
	var section : String = get_config_section()
	if section == "":
		return
	
	if _favored_joypad_name != "":
		conf.set_value(section, "favored_joypad_name", _favored_joypad_name)
	
	var group_list : Array = get_group_list()
	for group_name in group_list:
		var action_list : Array = get_group_action_list(group_name)
		for action_data in action_list:
			if InputMap.has_action(action_data.name):
				var actions : Array = InputMap.get_action_list(action_data.name)
				for action in actions:
					match action.get_class():
						"InputEventKey":
							var scancode : int = _IEKScancode(action)
							conf.set_value(section, "%s.%s.scancode"%[group_name, action_data.name], scancode)
						"InputEventMouseButton":
							conf.set_value(section, "%s.%s.mouse_button"%[group_name, action_data.name], action.button_index)
						"InputEventJoypadAxis":
							conf.set_value(section, "%s.%s.joy_axis"%[group_name, action_data.name], action.axis)
						"InputEventJoypadButton":
							conf.set_value(section, "%s.%s.joy_button"%[group_name, action_data.name], action.button_index)


func get_project_name() -> String:
	if ProjectSettings.has_setting(SETTINGS_SECTION_VAR):
		var proj = ProjectSettings.get_setting(SETTINGS_SECTION_VAR)
		if typeof(proj) == TYPE_STRING and proj.is_valid_identifier():
			return proj
	return ""

func set_config_section(section : String) -> bool:
	if Engine.editor_hint and section.is_valid_identifier() and ProjectSettings.has_setting(SETTINGS_CONF_SECTION_VAR):
		ProjectSettings.set_setting(SETTINGS_CONF_SECTION_VAR, section)
		return true
	return false

func get_config_section() -> String:
	if ProjectSettings.has_setting(SETTINGS_CONF_SECTION_VAR):
		var sec = ProjectSettings.get_setting(SETTINGS_CONF_SECTION_VAR)
		if typeof(sec) == TYPE_STRING:
			return sec
	return ""

func set_group(group_name : String, unique_inputs : bool = true, preserve_actions : bool = false) -> bool:
	var project_name : String = get_project_name()
	if project_name == "":
		return false
	
	if not group_name.is_valid_identifier():
		printerr("EIM ERROR: Extended Input Group Name identifier, \"", group_name, "\" invalid.")
		return false
	
	var key = project_name + SUBPROP_EI_GROUPS + group_name
	var data = {"unique_inputs":unique_inputs, "actions":[]}
	if ProjectSettings.has_setting(key):
		data = ProjectSettings.get_setting(key)
		data.unique_inputs = unique_inputs
		if not preserve_actions:
			data.actions = []
	ProjectSettings.set_setting(key, data)
	
	var glist : Array = get_group_list()
	if glist.find(group_name) < 0:
		glist.append(group_name)
		ProjectSettings.set_setting(project_name + PROP_EI_GROUP_LIST, glist)
	return true

func drop_group(group_name : String) -> void:
	var project_name : String = get_project_name()
	if project_name == "":
		return
	
	var key = project_name + SUBPROP_EI_GROUPS + group_name
	if ProjectSettings.has_setting(key):
		var glist : Array = get_group_list()
		var idx : int = glist.find(group_name)
		if idx < 0:
			printerr("EIM ERROR: Extended input group \"", group_name, "\" found, but not listed.")
			return
		glist.remove(idx)
		ProjectSettings.set_setting(key, null)
		ProjectSettings.set_setting(project_name + PROP_EI_GROUP_LIST, glist)

func set_group_inputs_unique(group_name : String, unique : bool = true) -> bool:
	return set_group(group_name, unique, true)

func are_group_inputs_unique(group_name : String) -> bool:
	var project_name : String = get_project_name()
	if project_name == "":
		return false
		
	var key = project_name + SUBPROP_EI_GROUPS + group_name
	if ProjectSettings.has_setting(key):
		var data = ProjectSettings.get_setting(key)
		return data.unique_inputs
	return false

func get_group_list() -> Array:
	var project_name : String = get_project_name()
	if project_name != "":
		if ProjectSettings.has_setting(project_name + PROP_EI_GROUP_LIST):
			return ProjectSettings.get_setting(project_name + PROP_EI_GROUP_LIST)
	return []


func add_action_to_group(group_name : String, action_name : String) -> bool:
	var project_name : String = get_project_name()
	if project_name == "":
		return false
	
	if not group_name.is_valid_identifier():
		printerr("EIM ERROR: Extended Input Group Name identifier, \"", group_name, "\" invalid.")
		return false
	
	var action = _GetProjectSettingsAction(action_name)
	if action == null:
		return false
	
	
	var key = project_name + SUBPROP_EI_GROUPS + group_name
	if not ProjectSettings.has_setting(key):
		return false
	var data = ProjectSettings.get_setting(key)
	
	# Lets make sure the action is not stored in any other group
	# if it is, remove it.
	var glist = get_group_list()
	var desc : String = ""
	for gname in glist:
		var gkey : String = project_name + SUBPROP_EI_GROUPS + gname
		if not ProjectSettings.has_setting(gkey):
			continue
		var gdata = ProjectSettings.get_setting(gkey)
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
	var project_name : String = get_project_name()
	if project_name == "":
		return
		
	if not group_name.is_valid_identifier():
		printerr("EIM ERROR: Extended Input Group Name identifier, \"", group_name, "\" invalid.")
		return
	var key = project_name + SUBPROP_EI_GROUPS + group_name
	if ProjectSettings.has_setting(key):
		var data = ProjectSettings.get_setting(key)
		var idx : int = _FindDataAction(data, action_name)
		if idx >= 0:
			data.actions.remove(idx)
			ProjectSettings.set_setting(key, data)

func set_group_action_description(group_name : String, action_name : String, description : String) -> void:
	var project_name : String = get_project_name()
	if project_name == "":
		return
	
	if not group_name.is_valid_identifier():
		printerr("EIM ERROR: Extended Input Group Name identifier, \"", group_name, "\" invalid.")
		return
	var key = project_name + SUBPROP_EI_GROUPS + group_name
	if ProjectSettings.has_setting(key):
		var data = ProjectSettings.get_setting(key)
		var idx : int = _FindDataAction(data, action_name)
		if idx >= 0:
			data.actions[idx].desc = description
			ProjectSettings.set_setting(key, data)

func get_group_action_description(group_name : String, action_name : String) -> String:
	# TODO: Write this method you fool!
	return ""

func get_group_action_list(group_name : String) -> Array:
	var adlist : Array = []
	var project_name : String = get_project_name()
	if project_name != "" and group_name.is_valid_identifier():
		var key = project_name + SUBPROP_EI_GROUPS + group_name
		if ProjectSettings.has_setting(key):
			var data = ProjectSettings.get_setting(key)
			for adat in data.actions:
				adlist.append({"name":adat.name, "desc":adat.desc})
	return adlist

func is_action_assigned_group(action_name : String) -> bool:
	var glist = get_group_list()
	for group_name in glist:
		if is_action_in_group(group_name, action_name):
			return true
	return false

func is_action_in_group(group_name : String, action_name : String) -> bool:
	var project_name : String = get_project_name()
	if project_name == "":
		return false
	
	var key = project_name + SUBPROP_EI_GROUPS + group_name
	if ProjectSettings.has_setting(key):
		var data = ProjectSettings.get_setting(key)
		return _FindDataAction(data, action_name) >= 0
	return false

func is_group_actions_unique(group_name : String) -> bool:
	var alist = get_group_action_list(group_name)
	if alist.size() > 0:
		for a1idx in range(alist.size() - 1):
			for a2idx in range(a1idx + 1, alist.size()):
				if not _AreActionsUnique(alist[a1idx].name, alist[a2idx].name):
					return false
	return true


func is_group_action_inputs_unique(group_name : String, action_name : String) -> bool:
	if not is_action_in_group(group_name, action_name):
		return false
	var alist = get_group_action_list(group_name)
	if alist.size() > 0:
		for adata in alist:
			if adata.name != action_name:
				if Engine.editor_hint:
					if not _AreActionsUniqueEditorMode(action_name, adata.name):
						return false
				else:
					if not _AreActionsUnique(action_name, adata.name):
						return false
	return true

func add_group_action_input(group_name : String, action_name : String, input : InputEvent) -> void:
	if not is_action_in_group(group_name, action_name):
		printerr("EIM ERROR: Action \"", action_name, "\" not assigned group \"", group_name, "\". Ignoring due to possible conflict with ungrouped input(s).")
		return
	if not action_has_input(action_name, input):
		InputMap.action_add_event(action_name, input)

func replace_group_action_input(group_name : String, action_name : String, old_input : InputEvent, new_input : InputEvent) -> void:
	if not is_action_in_group(group_name, action_name):
		printerr("EIM ERROR: Action \"", action_name, "\" not assigned group \"", group_name, "\". Ignoring due to possible conflict with ungrouped input(s).")
		return
	
	if old_input.get_class() != new_input.get_class():
		printerr("EIM ERROR: Old input event not same type as new input event.")
		return # Only replace inputs of the same type
	
	if not InputMap.has_action(action_name):
		return
	
	for event in InputMap.get_action_list(action_name):
		var event_class : String = event.get_class()
		if event.get_class() == old_input.get_class():
			# NOTE: Assuming modification in-place will work here.
			match event.get_class():
				"InputEventKey":
					var old_scancode = _IEKScancode(old_input)
					var e_scancode = _IEKScancode(event)
					if e_scancode == old_scancode:
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


func action_has_input(action_name : String, input : InputEvent) -> bool:
	if not InputMap.has_action(action_name):
		return false
	
	var input_class : String = input.get_class()
	for event in InputMap.get_action_list(action_name):
		if event.get_class() == input_class:
			match input_class:
				"InputEventKey":
					var i_scancode = _IEKScancode(input)
					var e_scancode = _IEKScancode(event)
					if e_scancode == i_scancode:
						return true
				"InputEventMouseButton":
					if event.button_index == input.button_index:
						return true
				"InputEventJoypadMotion":
					if event.axis == input.axis:
						return true
				"InputEventJoypadButton":
					if event.button_index == input.button_index:
						return true
	return false


func action_has_input_type(action_name : String, input_type : String) -> bool:
	if InputMap.has_action(action_name):
		for event in InputMap.get_action_list(action_name):
			if event.get_class() == input_type:
				return true
	return false

func action_has_key_inputs(action_name : String) -> bool:
	return action_has_input_type(action_name, "InputEventKey")

func action_has_mouse_inputs(action_name : String) -> bool:
	return action_has_input_type(action_name, "InputEventMouseButton")


func action_has_joypad_button_inputs(action_name : String) -> bool:
	return action_has_input_type(action_name, "InputEventJoypadButton")

func action_has_joypad_axii_inputs(action_name : String) -> bool:
	return action_has_input_type(action_name, "InputEventJoypadMotion")

func reset_actions_to_default() -> void:
	InputMap.load_from_globals()

# -----------------------------------------------------------------------------
# Joypad-Related Public Methods
# -----------------------------------------------------------------------------

func get_joypad_list() -> Array:
	var joys : Array = []
	var conjoy : Array = Input.get_connected_joypads()
	for did in conjoy:
		joys.append({
			"id": did,
			"name": Input.get_joy_name(did)
		})
	return joys

func set_active_joypad_id(idx : int) -> void:
	if Input.get_joy_name(idx) != "":
		_active_joypad_id = idx
		_UpdateJoypadActions()
		emit_signal("active_joypad_changed", _active_joypad_id, Input.get_joy_name(_active_joypad_id))

func get_active_joypad_id() -> int:
	return _active_joypad_id

func get_active_joypad_name() -> String:
	return Input.get_joy_name(_active_joypad_id)

func set_active_joypad_as_favored() -> void:
	_favored_joypad_name = Input.get_joy_name(_active_joypad_id)

func set_joypad_to_first_identified() -> bool:
	var conjoy : Array = Input.get_connected_joypads()
	if conjoy.size() > 0:
		set_active_joypad_id(conjoy[0])
		return true
	return false

func _on_joy_connection_changed(device_id : int, connected : bool) -> void:
	if connected:
		var joy_name : String = Input.get_joy_name(device_id)
		if joy_name == _favored_joypad_name:
			set_active_joypad_id(device_id) 

