extends Control
tool

# -----------------------------------------------------------------------------
# Signals
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
const InputMonitorDialog = preload("res://addons/eim/ui/InputMonitorDialog/InputMonitorDialog.tscn")
const ThemeWrapper = preload("res://addons/eim/scripts/ThemeWrapper.gd")

const _COLUMN_DESCRIPTION : int = 0

const _INPUT_KEY : int = 0
const _INPUT_MOUSE : int = 1
const _INPUT_JOY_BUTTON : int = 2
const _INPUT_JOY_AXIS : int = 3

const _THEME_HEADER_BG_DEFAULT : Color = Color(0.25098, 0.270588, 0.32549)
const _THEME_HEADER_LABEL_DEFAULT : Color = Color(0.647059, 0.937255, 0.67451)

# -----------------------------------------------------------------------------
# "Export" Variables
# -----------------------------------------------------------------------------
var _group_name : String = ""
var _joypad_lookup_group : String = "XBox"
var _rel_action_spacing : float = 0.1

var _display_header : bool = true
var _enable_key_bindings : bool = true
var _enable_mouse_bindings : bool = true
var _enable_joy_bindings : bool = true
var _merge_joy_button_axis : bool = false

# ---
# Theme Items
var _theme_header_bg = null
var _theme_header_label = null

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
var _binding_column = {
	_INPUT_KEY: 1,
	_INPUT_MOUSE: 2,
	_INPUT_JOY_BUTTON: 3,
	_INPUT_JOY_AXIS: 4
}

var _root : TreeItem = null
var _last_selected : Dictionary = {"item":null, "column":-1, "color":Color(0,0,0)}

var _tw = null

var _joybtn_lut : Dictionary = {
	"xbox": {
		JOY_BUTTON_0 : {"text": "A", "icon":preload("res://addons/eim/icons/controller/btn_A.svg")},
		JOY_BUTTON_1 : {"text": "B", "icon":preload("res://addons/eim/icons/controller/btn_B.svg")},
		JOY_BUTTON_2 : {"text": "X", "icon":preload("res://addons/eim/icons/controller/btn_X.svg")},
		JOY_BUTTON_3 : {"text": "Y", "icon":preload("res://addons/eim/icons/controller/btn_Y.svg")},
	
		JOY_BUTTON_4: {"text": "LB", "icon":preload("res://addons/eim/icons/controller/btn_l1.svg")},
		JOY_BUTTON_5: {"text": "RB", "icon":preload("res://addons/eim/icons/controller/btn_r1.svg")},
		JOY_BUTTON_6: {"text": "LT", "icon":preload("res://addons/eim/icons/controller/axis_l2.svg")},
		JOY_BUTTON_7: {"text": "RT", "icon":preload("res://addons/eim/icons/controller/axis_r2.svg")},
		JOY_BUTTON_8: {"text": "L3", "icon":preload("res://addons/eim/icons/controller/btn_L3.svg")},
		JOY_BUTTON_9: {"text": "R3", "icon":preload("res://addons/eim/icons/controller/btn_R3.svg")},
		
		JOY_BUTTON_10: {"text": "Start", "icon":null},
		JOY_BUTTON_11: {"text": "Select", "icon":null},
	
		JOY_BUTTON_12 : {"text": "DPad Up", "icon":preload("res://addons/eim/icons/controller/btn_dpad_UP.svg")},
		JOY_BUTTON_13 : {"text": "DPad Down", "icon":preload("res://addons/eim/icons/controller/btn_dpad_DOWN.svg")},
		JOY_BUTTON_14 : {"text": "DPad Left", "icon":preload("res://addons/eim/icons/controller/btn_dpad_LEFT.svg")},
		JOY_BUTTON_15 : {"text": "DPad Right", "icon":preload("res://addons/eim/icons/controller/btn_dpad_RIGHT.svg")},
	},
	"sony": {
		JOY_BUTTON_0 : {"text": "X", "icon":null},
		JOY_BUTTON_1 : {"text": "Circle", "icon":null},
		JOY_BUTTON_2 : {"text": "Square", "icon":null},
		JOY_BUTTON_3 : {"text": "Triangle", "icon":null},
		
		JOY_BUTTON_4: {"text": "L1", "icon":preload("res://addons/eim/icons/controller/btn_l1.svg")},
		JOY_BUTTON_5: {"text": "R1", "icon":preload("res://addons/eim/icons/controller/btn_r1.svg")},
		JOY_BUTTON_6: {"text": "L2", "icon":preload("res://addons/eim/icons/controller/axis_l2.svg")},
		JOY_BUTTON_7: {"text": "R2", "icon":preload("res://addons/eim/icons/controller/axis_r2.svg")},
		JOY_BUTTON_8: {"text": "L3", "icon":preload("res://addons/eim/icons/controller/btn_L3.svg")},
		JOY_BUTTON_9: {"text": "R3", "icon":preload("res://addons/eim/icons/controller/btn_R3.svg")},
		
		JOY_BUTTON_10: {"text": "Start", "icon":null},
		JOY_BUTTON_11: {"text": "Select", "icon":null},
		
		JOY_BUTTON_12 : {"text": "DPad Up", "icon":preload("res://addons/eim/icons/controller/btn_dpad_UP.svg")},
		JOY_BUTTON_13 : {"text": "DPad Down", "icon":preload("res://addons/eim/icons/controller/btn_dpad_DOWN.svg")},
		JOY_BUTTON_14 : {"text": "DPad Left", "icon":preload("res://addons/eim/icons/controller/btn_dpad_LEFT.svg")},
		JOY_BUTTON_15 : {"text": "DPad Right", "icon":preload("res://addons/eim/icons/controller/btn_dpad_RIGHT.svg")},
	},
	"nintendo": {
		JOY_BUTTON_0 : {"text": "B", "icon":preload("res://addons/eim/icons/controller/btn_B.svg")},
		JOY_BUTTON_1 : {"text": "A", "icon":preload("res://addons/eim/icons/controller/btn_A.svg")},
		JOY_BUTTON_2 : {"text": "Y", "icon":preload("res://addons/eim/icons/controller/btn_Y.svg")},
		JOY_BUTTON_3 : {"text": "X", "icon":preload("res://addons/eim/icons/controller/btn_X.svg")},
		
		JOY_BUTTON_4: {"text": "LB", "icon":preload("res://addons/eim/icons/controller/btn_l1.svg")},
		JOY_BUTTON_5: {"text": "RB", "icon":preload("res://addons/eim/icons/controller/btn_r1.svg")},
		JOY_BUTTON_6: {"text": "LT", "icon":preload("res://addons/eim/icons/controller/axis_l2.svg")},
		JOY_BUTTON_7: {"text": "RT", "icon":preload("res://addons/eim/icons/controller/axis_r2.svg")},
		JOY_BUTTON_8: {"text": "L3", "icon":preload("res://addons/eim/icons/controller/btn_L3.svg")},
		JOY_BUTTON_9: {"text": "R3", "icon":preload("res://addons/eim/icons/controller/btn_R3.svg")},
		
		JOY_BUTTON_10: {"text": "Start", "icon":null},
		JOY_BUTTON_11: {"text": "Select", "icon":null},
		
		JOY_BUTTON_12 : {"text": "DPad Up", "icon":preload("res://addons/eim/icons/controller/btn_dpad_UP.svg")},
		JOY_BUTTON_13 : {"text": "DPad Down", "icon":preload("res://addons/eim/icons/controller/btn_dpad_DOWN.svg")},
		JOY_BUTTON_14 : {"text": "DPad Left", "icon":preload("res://addons/eim/icons/controller/btn_dpad_LEFT.svg")},
		JOY_BUTTON_15 : {"text": "DPad Right", "icon":preload("res://addons/eim/icons/controller/btn_dpad_RIGHT.svg")},
	}
}

var _joyaxis_lut : Dictionary = {
	"xbox": {
		JOY_ANALOG_LX : {"text": "Left Thumb X", "icon":preload("res://addons/eim/icons/controller/axis_left_h.svg")},
		JOY_ANALOG_LY : {"text": "Left Thumb Y", "icon":preload("res://addons/eim/icons/controller/axis_left_v.svg")},
		JOY_ANALOG_RX : {"text": "Right Thumb X", "icon":preload("res://addons/eim/icons/controller/axis_right_h.svg")},
		JOY_ANALOG_RY : {"text": "Right Thumb Y", "icon":preload("res://addons/eim/icons/controller/axis_right_v.svg")},
		JOY_ANALOG_L2 : {"text": "LT", "icon":preload("res://addons/eim/icons/controller/axis_l2.svg")},
		JOY_ANALOG_R2 : {"text": "RT", "icon":preload("res://addons/eim/icons/controller/axis_r2.svg")},
	},
	
	"sony":{
		JOY_ANALOG_LX : {"text": "Left Thumb X", "icon":preload("res://addons/eim/icons/controller/axis_left_h.svg")},
		JOY_ANALOG_LY : {"text": "Left Thumb Y", "icon":preload("res://addons/eim/icons/controller/axis_left_v.svg")},
		JOY_ANALOG_RX : {"text": "Right Thumb X", "icon":preload("res://addons/eim/icons/controller/axis_right_h.svg")},
		JOY_ANALOG_RY : {"text": "Right Thumb Y", "icon":preload("res://addons/eim/icons/controller/axis_right_v.svg")},
		JOY_ANALOG_L2 : {"text": "L2", "icon":preload("res://addons/eim/icons/controller/axis_l2.svg")},
		JOY_ANALOG_R2 : {"text": "R2", "icon":preload("res://addons/eim/icons/controller/axis_r2.svg")},
	},
	
	"nintendo":{
		JOY_ANALOG_LX : {"text": "Left Thumb X", "icon":preload("res://addons/eim/icons/controller/axis_left_h.svg")},
		JOY_ANALOG_LY : {"text": "Left Thumb Y", "icon":preload("res://addons/eim/icons/controller/axis_left_v.svg")},
		JOY_ANALOG_RX : {"text": "Right Thumb X", "icon":preload("res://addons/eim/icons/controller/axis_right_h.svg")},
		JOY_ANALOG_RY : {"text": "Right Thumb Y", "icon":preload("res://addons/eim/icons/controller/axis_right_v.svg")},
		JOY_ANALOG_L2 : {"text": "LT", "icon":preload("res://addons/eim/icons/controller/axis_l2.svg")},
		JOY_ANALOG_R2 : {"text": "RT", "icon":preload("res://addons/eim/icons/controller/axis_r2.svg")},
	}
}

# -----------------------------------------------------------------------------
# Onready Variables
# -----------------------------------------------------------------------------
onready var tree_node : Tree = $Tree

# -----------------------------------------------------------------------------
# Setters/Getters
# -----------------------------------------------------------------------------
func set_group_name(gn : String, force : bool = false) -> void:
	if (gn == "" or gn.is_valid_identifier()) and (gn != _group_name or force == true):
		_group_name = gn
		if _group_name == "":
			_ClearList()
		else:
			_BuildList()

func set_rel_action_spacing(s : float) -> void:
	if s > 0.0 and s < 1.0:
		_rel_action_spacing = s
		_UpdateColumnSpacing()

func set_enable_key_bindings(e : bool) -> void:
	if _enable_key_bindings != e:
		_enable_key_bindings = e
		_BuildList(true)

func set_enable_mouse_bindings(e : bool) -> void:
	if _enable_mouse_bindings != e:
		_enable_mouse_bindings = e
		_BuildList(true)

func set_enable_joy_bindings(e : bool) -> void:
	if _enable_joy_bindings != e:
		_enable_joy_bindings = e
		_BuildList(true)

func set_merge_joy_button_axis(e : bool) -> void:
	if _merge_joy_button_axis != e:
		_merge_joy_button_axis = e
		_BuildList(true)

func set_joypad_lookup_group(g : String) -> void:
	if g != _joypad_lookup_group:
		_joypad_lookup_group = g
		_BuildList(true)

# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	if _tw == null:
		_tw = ThemeWrapper.new()
	_tw.default_theme_type = "InputBinder"
	_tw.add_control_source(tree_node)
	
	tree_node.connect("item_activated", self, "_on_item_activated")
	tree_node.connect("item_selected", self, "_on_item_selected")
	tree_node.connect("nothing_selected", self, "_on_nothing_selected")
	tree_node.connect("resized", self, "_UpdateColumnSpacing")
	tree_node.connect("focus_entered", self, "_on_focus_entered")
	tree_node.connect("focus_exited", self, "_on_focus_exited")
#	var props = tree_node.get_property_list()
#	var prev_prop = null
#	for prop in props:
#		if prop.name == "custom_colors/custom_button_font_highlight":
#			for key in prop.keys():
#				print(key, ": ", prop[key])
#			print("---")
#			if prev_prop:
#				for key in prev_prop.keys():
#					print(key, ": ", prev_prop[key])
#				print("---")
#		prev_prop = prop


func _get(property : String):
	match property:
		"group_name":
			return _group_name
		"joypad_lookup_group":
			return _joypad_lookup_group
		"rel_action_spacing":
			return _rel_action_spacing
		"display_header":
			return _display_header
		"enable_key_bindings":
			return _enable_key_bindings
		"enable_mouse_bindings":
			return _enable_mouse_bindings
		"enable_joy_bindings":
			return _enable_joy_bindings
		"merge_joy_button_axis":
			return _merge_joy_button_axis
		"custom_colors/header_background":
			return _theme_header_bg
		"custom_colors/header_label":
			return _theme_header_label
		_:
			if _tw != null:
				return _tw.get_property(property)
	return null


func _set(property : String, value) -> bool:
	var success : bool = true
	match property:
		"group_name":
			if typeof(value) == TYPE_STRING:
				set_group_name(value)
			else : success = false
		"joypad_lookup_group":
			if typeof(value) == TYPE_STRING:
				set_joypad_lookup_group(value)
			else : success = false
		"rel_action_spacing":
			if typeof(value) == TYPE_REAL:
				set_rel_action_spacing(value)
			else : success = false
		"display_header":
			if typeof(value) == TYPE_BOOL:
				_display_header = value
			else : success = false
		"enable_key_bindings":
			if typeof(value) == TYPE_BOOL:
				set_enable_key_bindings(value)
			else : success = false
		"enable_mouse_bindings":
			if typeof(value) == TYPE_BOOL:
				set_enable_mouse_bindings(value)
			else : success = false
		"enable_joy_bindings":
			if typeof(value) == TYPE_BOOL:
				set_enable_joy_bindings(value)
			else : success = false
		"merge_joy_button_axis":
			if typeof(value) == TYPE_BOOL:
				set_merge_joy_button_axis(value)
			else : success = false
		"custom_colors/header_background":
			if value == null or typeof(value) == TYPE_COLOR:
				_theme_header_bg = value
				call_deferred("_CustomTheme")
			else : success = false
		"custom_colors/header_label":
			if value == null or typeof(value) == TYPE_COLOR:
				_theme_header_label = value
				call_deferred("_CustomTheme")
			else : success = false
		_:
			if _tw != null:
				success = _tw.set_property(property, value)
			else:
				success = false
	if success:
		property_list_changed_notify()
	return success


func _get_property_list() -> Array:
	if _tw == null:
		_tw = ThemeWrapper.new()
	var arr : Array = [
		{
			name="InputBinder",
			type=TYPE_NIL,
			usage=PROPERTY_USAGE_CATEGORY
		},
		{
			name="group_name",
			type=TYPE_STRING,
			usage=PROPERTY_USAGE_DEFAULT
		},
		{
			name="joypad_lookup_group",
			type=TYPE_STRING,
			usage=PROPERTY_USAGE_DEFAULT
		},
		{
			name="rel_action_spacing",
			type=TYPE_REAL,
			hint=PROPERTY_HINT_RANGE,
			hint_string="float, 0.01, 0.99",
			usage=PROPERTY_USAGE_DEFAULT
		},
		{
			name="Header",
			type=TYPE_NIL,
			usage=PROPERTY_USAGE_GROUP
		},
		{
			name="display_header",
			type=TYPE_BOOL,
			usage=PROPERTY_USAGE_DEFAULT
		},
		{
			name="enable_key_bindings",
			type=TYPE_BOOL,
			usage=PROPERTY_USAGE_DEFAULT
		},
		{
			name="enable_mouse_bindings",
			type=TYPE_BOOL,
			usage=PROPERTY_USAGE_DEFAULT
		},
		{
			name="enable_joy_bindings",
			type=TYPE_BOOL,
			usage=PROPERTY_USAGE_DEFAULT
		},
		{
			name="merge_joy_button_axis",
			type=TYPE_BOOL,
			usage=PROPERTY_USAGE_DEFAULT
		},
	]
	if _tw != null:
		_tw.add_custom_property("custom_colors/header_background", _theme_header_bg != null)
		_tw.add_custom_property("custom_colors/header_label", _theme_header_label != null)
		return _tw.inject_theme_property_list(arr)
	return arr


# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------
func _CustomTheme() -> void:
	if not _root:
		return
	
	var header : TreeItem = _root.get_children()
	if not header:
		return
	
	var bg : Color = get_color("header_background")
	var label : Color = get_color("header_label")
	var columns = _ColumnCount()
	for i in range(columns):
		header.set_custom_bg_color(columns, bg)
		header.set_custom_color(columns, label)

func _IsThemeProperty(property : String, stype : String) -> bool:
	var idx : int = property.find("/")
	if idx > 0:
		var prefix : String = property.substr(0, idx)
		return prefix == ("custom_%s"%[stype])
	return false

func _WatchForInput(input_focus : int) -> void:
	var imd = InputMonitorDialog.instance()
	imd.input_focus = input_focus
	imd.connect("input_captured", self, "_on_input_captured", [imd])
	imd.connect("input_monitor_canceled", self, "_on_input_canceled", [imd])
	add_child(imd)
	imd.popup_centered()


func _ActionExists(action_name : String) -> bool:
	if Engine.editor_hint:
		return ProjectSettings.has_setting("%s%s"%[EIM.SUBPROP_INPUT, action_name])
	return InputMap.has_action(action_name)

func _GetActionEventList(action_name : String) -> Array:
	if Engine.editor_hint:
		var action = ProjectSettings.get_setting("%s%s"%[EIM.SUBPROP_INPUT, action_name])
		if action != null:
			return action.events
	return InputMap.get_action_list(action_name)

func _SettingNameToHumanReadable(setting_name : String) -> String:
	var last_idx : int = setting_name.find_last("/")
	if last_idx >= 0:
		setting_name = setting_name.substr(last_idx + 1, setting_name.length() - (last_idx+1))
	return setting_name.replace("_", " ").capitalize()

func _ColumnCount() -> int:
	var columns : int = 1
	if _enable_key_bindings:
		columns += 1
	if _enable_mouse_bindings:
		columns += 1
	if _enable_joy_bindings:
		columns += 1 if _merge_joy_button_axis else 2
	return columns

func _BuildBindingColumns() -> int:
	# -- Calculates the column in the tree the input values are associated and
	#  returns the number of indexes used.
	var idx : int = 1
	if _enable_key_bindings:
		_binding_column[_INPUT_KEY] = idx
		idx += 1
	else:
		_binding_column[_INPUT_KEY] = -1
		
	if _enable_mouse_bindings:
		_binding_column[_INPUT_MOUSE] = idx
		idx += 1
	else:
		_binding_column[_INPUT_MOUSE] = -1
	
	if _enable_joy_bindings:
		_binding_column[_INPUT_JOY_BUTTON] = idx
		if not _merge_joy_button_axis:
			idx += 1
		_binding_column[_INPUT_JOY_AXIS] = idx
	else:
		_binding_column[_INPUT_JOY_AXIS] = -1
		_binding_column[_INPUT_JOY_BUTTON] = -1

	return idx

func _UpdateColumnSpacing() -> void:
	if tree_node == null:
		return
		
	var columns : int = _ColumnCount()
	if tree_node.columns != columns:
		return
		
	var spacing = _rel_action_spacing
	var total_spacing : float = spacing * columns
	if total_spacing >= 1.0:
		total_spacing = 0.75
		spacing = total_spacing / columns
	spacing = rect_size.x * spacing
	
	tree_node.set_column_min_width(_COLUMN_DESCRIPTION, rect_size.x * (1.0 - total_spacing))
	for col in range(columns):
		if col != _COLUMN_DESCRIPTION:
			tree_node.set_column_min_width(col, spacing)


func _ClearList(clear_root : bool = false) -> void:
	if _root == null:
		return
	
	_ClearLastItem()
	var item : TreeItem = _root.get_children()
	if item != null:
		_root.remove_child(item)
		item.free()
		_ClearList()
	
	if clear_root:
		_root.free()
		tree_node.clear()

func _BuildListHeader() -> void:
	if tree_node != null and _root != null:
		var bg : Color = get_color("header_background")
		var label : Color = get_color("header_label")
		var header : TreeItem = tree_node.create_item(_root)
		header.set_custom_bg_color(_COLUMN_DESCRIPTION, bg)
		header.set_selectable(_COLUMN_DESCRIPTION, false)
		if _binding_column[_INPUT_KEY] >= 0:
			header.set_custom_bg_color(_binding_column[_INPUT_KEY], bg)
			header.set_icon_modulate(_binding_column[_INPUT_KEY], label)
			header.set_selectable(_binding_column[_INPUT_KEY], false)
			header.set_text_align(_binding_column[_INPUT_KEY], TreeItem.ALIGN_CENTER)
			header.set_icon(_binding_column[_INPUT_KEY], preload("res://addons/eim/icons/input_keyboard.svg"))
		if _binding_column[_INPUT_MOUSE] >= 0:
			header.set_custom_bg_color(_binding_column[_INPUT_MOUSE], bg)
			header.set_icon_modulate(_binding_column[_INPUT_MOUSE], label)
			header.set_selectable(_binding_column[_INPUT_MOUSE], false)
			header.set_text_align(_binding_column[_INPUT_MOUSE], TreeItem.ALIGN_CENTER)
			header.set_icon(_binding_column[_INPUT_MOUSE], preload("res://addons/eim/icons/input_mouse.svg"))
		if _binding_column[_INPUT_JOY_AXIS] >= 0:
			header.set_custom_bg_color(_binding_column[_INPUT_JOY_AXIS], bg)
			header.set_icon_modulate(_binding_column[_INPUT_JOY_AXIS], label)
			header.set_selectable(_binding_column[_INPUT_JOY_AXIS], false)
			header.set_text_align(_binding_column[_INPUT_JOY_AXIS], TreeItem.ALIGN_CENTER)
			if _merge_joy_button_axis:
				header.set_icon(_binding_column[_INPUT_JOY_AXIS], preload("res://addons/eim/icons/input_joypad.svg"))
			else:
				header.set_icon(_binding_column[_INPUT_JOY_AXIS], preload("res://addons/eim/icons/input_joypad_axii.svg"))
				
				header.set_custom_bg_color(_binding_column[_INPUT_JOY_BUTTON], bg)
				header.set_icon_modulate(_binding_column[_INPUT_JOY_BUTTON], label)
				header.set_selectable(_binding_column[_INPUT_JOY_BUTTON], false)
				header.set_text_align(_binding_column[_INPUT_JOY_BUTTON], TreeItem.ALIGN_CENTER)
				header.set_icon(_binding_column[_INPUT_JOY_BUTTON], preload("res://addons/eim/icons/input_joypad_buttons.svg"))


func _BuildList(full_rebuild : bool = false) -> void:
	if tree_node == null:
		return

	if _group_name.is_valid_identifier():
		var alist : Array = EIM.get_group_action_list(_group_name)
		if alist.size() > 0:
			if _root == null or full_rebuild:
				if full_rebuild:
					_ClearList(full_rebuild)
				_BuildBindingColumns()
				var cols = _ColumnCount()
				if tree_node.columns != cols:
					tree_node.columns = cols
				_UpdateColumnSpacing()
				_root = tree_node.create_item()
				tree_node.set_hide_root(true)
			else:
				_ClearList()
			
			_BuildListHeader()
			for ainfo in alist:
				if not _ActionExists(ainfo.name):
					continue
				var action_list : Array = _GetActionEventList(ainfo.name)
				
				var item = tree_node.create_item(_root)
				item.set_metadata(_COLUMN_DESCRIPTION, ainfo.name)
				if ainfo.desc != "":
					item.set_text(_COLUMN_DESCRIPTION, ainfo.desc)
				else:
					item.set_text(_COLUMN_DESCRIPTION, _SettingNameToHumanReadable(ainfo.name))
				item.set_selectable(0, false)
				
				for event in action_list:
					var column : int = -1
					var info : Dictionary = {"text":"", "icon":null}
					match event.get_class():
						"InputEventKey":
							if _enable_key_bindings:
								column = _binding_column[_INPUT_KEY]
								info.text = OS.get_scancode_string(
									event.scancode if event.scancode != 0 else event.physical_scancode
								)
						"InputEventMouseButton":
							if _enable_mouse_bindings:
								column = _binding_column[_INPUT_MOUSE]
								match event.button_index:
									BUTTON_LEFT:
										info.text = "Left"
									BUTTON_RIGHT:
										info.text = "Right"
									BUTTON_MIDDLE:
										info.text = "Middle"
									BUTTON_WHEEL_UP:
										info.text = "Wheel Up"
									BUTTON_WHEEL_DOWN:
										info.text = "Wheel Down"
									BUTTON_WHEEL_LEFT:
										info.text = "Wheel Left"
									BUTTON_WHEEL_RIGHT:
										info.text = "Wheel Right"
									BUTTON_XBUTTON1:
										info.text = "Xtra 1"
									BUTTON_XBUTTON2:
										info.text = "Xtra 2"
						"InputEventJoypadButton":
							if _enable_joy_bindings:
								column = _binding_column[_INPUT_JOY_BUTTON]
								info = get_joypad_button_lookup(
									_joypad_lookup_group.to_lower(), event.button_index
								)
								if info.text == "":
									info.text = Input.get_joy_button_string(event.button_index)
						"InputEventJoypadAxis":
							if _enable_joy_bindings:
								column = _binding_column[_INPUT_JOY_AXIS]
								info = get_joypad_axis_lookup(
									_joypad_lookup_group.to_lower(), event.axis
								)
								if info.text == "":
									info.text = Input.get_joy_axis_string(event.axis)
					
					if column >= 0 and info.text != "":
						item.set_text_align(column, TreeItem.ALIGN_CENTER)
						if info.icon != null:
							item.set_icon(column, info.icon)
						else:
							item.set_text(column, info.text)
						item.set_metadata(column, event)
						if not EIM.is_group_action_inputs_unique(_group_name, ainfo.name):
							item.set_custom_bg_color(column, Color(1,0,0), true)


func _GetInputOrColumnClass(event : InputEvent, column : int) -> String:
	if event is InputEvent:
		return event.get_class()
	if column == _binding_column[_INPUT_KEY]:
		return "InputEventKey"
	if column == _binding_column[_INPUT_MOUSE]:
		return "InputEventMouseButton"
	if column == _binding_column[_INPUT_JOY_BUTTON]:
		if not _merge_joy_button_axis:
			return "InputEventJoypadButton"
		return "InputEventJoypad"
	if column == _binding_column[_INPUT_JOY_AXIS]:
		if not _merge_joy_button_axis:
			return "InputEventJoypadMotion"
		return "InputEventJoypad"
	return ""

func _ClearLastItem() -> void:
	_last_selected.item = null
	_last_selected.column = -1

func _SetLastItem(item : TreeItem, column : int) -> void:
	if item != null and column >= 0:
		_last_selected.item = item
		_last_selected.column = column
	else:
		_ClearLastItem()

# -----------------------------------------------------------------------------
# Public Methods
# -----------------------------------------------------------------------------
func set_joypad_button_lookup(type_name : String, idx : int, text : String, icon : Texture = null) -> void:
	if idx >= 0 and idx < JOY_BUTTON_MAX:
		type_name = type_name.to_lower()
		if not type_name in _joybtn_lut:
			_joybtn_lut[type_name] = {}
		_joybtn_lut[type_name][idx] = {
			"text": text,
			"icon": icon
		}
	else:
		printerr("Failed to set joypad button lookup. Joypad button index out of bounds.")

func get_joypad_button_lookup(type_name : String, idx : int) -> Dictionary:
	var res : Dictionary = {"text":"", "icon":null}
	type_name = type_name.to_lower()
	if type_name in _joybtn_lut:
		if idx in _joybtn_lut[type_name]:
			res.text = _joybtn_lut[type_name][idx].text
			res.icon = _joybtn_lut[type_name][idx].icon
	return res

func set_joypad_axis_lookup(type_name : String, idx : int, text : String, icon : Texture = null) -> void:
	if idx >= 0 and idx < JOY_AXIS_MAX:
		type_name = type_name.to_lower()
		if not type_name in _joyaxis_lut:
			_joyaxis_lut[type_name] = {}
		_joyaxis_lut[type_name][idx] = {
			"text": text,
			"icon": icon
		}
	else:
		printerr("Failed to set joypad axis lookup. Joypad axis index out of bounds.")

func get_joypad_axis_lookup(type_name : String, idx : int) -> Dictionary:
	var res : Dictionary = {"text":"", "icon":null}
	type_name = type_name.to_lower()
	if type_name in _joyaxis_lut:
		if idx in _joyaxis_lut[type_name]:
			res.text = _joyaxis_lut[type_name][idx].text
			res.icon = _joyaxis_lut[type_name][idx].icon
	return res

func add_color_override(property : String, value) -> void:
	if not _set("custom_colors/%s"%[property], value):
		.add_color_override(property, value)

func has_color_override(property : String) -> bool:
	var prop_name : String = "custom_colors/%s"%[property]
	match property:
		"custom_colors/header_background":
			return _theme_header_bg != null
		"custom_colors/header_label":
			return _theme_header_label != null
	if _tw.has_color_override(property):
		return true
	return .has_color_override(property)

func get_color(property : String, theme_type : String = "") -> Color:
	var prop_name : String = "custom_colors/%s"%[property]
	match prop_name:
		"custom_colors/header_background":
			if _theme_header_bg == null:
				if .has_color("header_background", _tw.default_theme_type):
					return .get_color("header_background", _tw.default_theme_type)
				return _THEME_HEADER_BG_DEFAULT
			return _theme_header_bg
		"custom_colors/header_label":
			if _theme_header_label == null:
				if .has_color("header_label", _tw.default_theme_type):
					return .get_color("header_label", _tw.default_theme_type)
				return _THEME_HEADER_LABEL_DEFAULT
			return _theme_header_label
	var c : Color = _tw.get_color(property, theme_type)
	if c == Color(0,0,0,1):
		return .get_color(property, theme_type)
	return c

func add_constant_override(property : String, value) -> void:
	if not _set("custom_colors/%s"%[property], value):
		.add_constant_override(property, value)

func has_constant_override(property : String) -> bool:
	if _tw.has_constant_override(property):
		return true
	return .has_constant_override(property)

func get_constant(property : String, theme_type : String = "") -> int:
	var v : int = _tw.get_constant(property, theme_type)
	if v == 0:
		return .get_constant(property, theme_type)
	return v

func add_font_override(property : String, value) -> void:
	if not _set("custom_fonts/%s"%[property], value):
		.add_font_override(property, value)

func has_font_override(property : String) -> bool:
	if _tw.has_font_override(property):
		return true
	return .has_font_override(property)

func get_font(property : String, theme_type : String = "") -> Font:
	var v : Font = _tw.get_font(property, theme_type)
	if v == null:
		return .get_font(property, theme_type)
	return v

func add_icon_override(property : String, value) -> void:
	if not _set("custom_icons/%s"%[property], value):
		.add_icon_override(property, value)

func has_icon_override(property : String) -> bool:
	if _tw.has_icon_override(property):
		return true
	return .has_icon_override(property)

func get_icon(property : String, theme_type : String = "") -> Texture:
	var v : Texture = _tw.get_icon(property, theme_type)
	if v == null:
		return .get_icon(property, theme_type)
	return v

func add_stylebox_override(property : String, value) -> void:
	if not _set("custom_styles/%s"%[property], value):
		.add_stylebox_override(property, value)

func has_stylebox_override(property : String) -> bool:
	if _tw.has_stylebox_override(property):
		return true
	return .has_stylebox_override(property)

func get_stylebox(property : String, theme_type : String = "") -> StyleBox:
	var v : StyleBox = _tw.get_stylebox(property, theme_type)
	if v == null:
		return .get_stylebox(property, theme_type)
	return v

# -----------------------------------------------------------------------------
# Handler Methods
# -----------------------------------------------------------------------------
func _on_input_captured(event, imd) -> void:
	remove_child(imd)
	imd.queue_free()
	if _last_selected.item != null and _last_selected.column >= 0:
		var meta = _last_selected.item.get_metadata(_last_selected.column)
		var meta_class : String = _GetInputOrColumnClass(meta, _last_selected.column)
		if meta_class == event.get_class():
			var action_name = _last_selected.item.get_metadata(_COLUMN_DESCRIPTION)
			if meta != null:
				EIM.replace_group_action_input(_group_name, action_name, meta, event)
			else:
				EIM.add_group_action_input(_group_name, action_name, event)
			_BuildList() # This is a little ham-fisted.
		else:
			printerr("Input Type Mismatch")
	else:
		printerr("Missing selected input")


func _on_input_canceled(imd) -> void:
	remove_child(imd)
	imd.queue_free()
	_ClearLastItem()


func _on_focus_entered() -> void:
	if _root == null:
		return
	
	if _last_selected.item != null and _last_selected.column >= 0:
		_last_selected.item.select(_last_selected.column)
	else:
		var item : TreeItem = _root.get_children()
		if item:
			item = item.get_next()
			if item:
				item.select(1)
	tree_node.ensure_cursor_is_visible()

func _on_focus_exited() -> void:
	if _last_selected.item != null:
		_last_selected.item.deselect(_last_selected.column)


func _on_item_activated() -> void:
	var item : TreeItem = tree_node.get_selected()
	if item:
		var column : int = tree_node.get_selected_column()
		var meta = item.get_metadata(column)
		_SetLastItem(item, column)
		if Engine.editor_hint:
			print("Input Mapping disabled in editor.")
		else:
			var iclass : String = _GetInputOrColumnClass(meta, column)
			match iclass:
				"InputEventKey":
					_WatchForInput(0)
				"InputEventMouseButton":
					_WatchForInput(1)
				"InputEventJoypadMotion":
					_WatchForInput(2)
				"InputEventJoypadButton":
					_WatchForInput(3)
				"InputEventJoypad":
					_WatchForInput(4)


func _on_item_selected() -> void:
	var item : TreeItem = tree_node.get_selected()
	if item:
		var column : int = tree_node.get_selected_column()
		if item.is_selectable(column):
			_SetLastItem(item, column)
	else:
		_ClearLastItem()

func _on_nothing_selected() -> void:
	_ClearLastItem()

