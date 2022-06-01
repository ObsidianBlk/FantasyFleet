tool
extends Control

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const COLUMN_DESCRIPTION : int = 0
const COLUMN_INPUT_KEY : int = 1
const COLUMN_INPUT_MOUSEBUTTON : int = 2
const COLUMN_INPUT_PAD_AXIS : int = 3
const COLUMN_INPUT_PAD_BUTTON : int = 4

const _THEME_TYPE_NAME : String = "GUIM"

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var group_name : String		setget set_group_name
export (float, 0.0, 0.2) var input_name_spacing : float = 0.1

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _root : TreeItem = null
var _last_selected : Dictionary = {"item":null, "column":-1, "color":Color(0,0,0)}


# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var tree_node : Tree = $Tree

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_group_name(gn : String, force : bool = false) -> void:
	if (gn == "" or gn.is_valid_identifier()) and (gn != group_name or force == true):
		group_name = gn
		if group_name == "":
			_ClearList()
		else:
			_BuildList()

func set_input_name_spacing(ins : float) -> void:
	if ins > 0.0 and ins <= 0.2:
		input_name_spacing = ins
		_UpdateColumnSpacing()

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	tree_node.columns = 5
	set_group_name(group_name, true)
	tree_node.connect("item_activated", self, "_on_item_activated")
	tree_node.connect("item_selected", self, "_on_item_selected")
	tree_node.connect("nothing_selected", self, "_on_nothing_selected")
	tree_node.connect("resized", self, "_UpdateColumnSpacing")
	tree_node.connect("focus_entered", self, "_on_focus_entered")
	tree_node.connect("focus_exited", self, "_on_focus_exited")
	_UpdateColumnSpacing()
	_SetupTheme()


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _SettingNameToHumanReadable(setting_name : String) -> String:
	var last_idx : int = setting_name.find_last("/")
	if last_idx >= 0:
		setting_name = setting_name.substr(last_idx + 1, setting_name.length() - (last_idx+1))
	return setting_name.replace("_", " ").capitalize()

func _BuildList() -> void:
	if group_name.is_valid_identifier():
		var alist : Array = EIM.get_group_action_list(group_name)
		if alist.size() > 0:
			if _root == null:
				_root = tree_node.create_item()
				tree_node.set_hide_root(true)
			else:
				_ClearList()
			
			for ainfo in alist:
				var action = ProjectSettings.get_setting(ainfo.name)
				if not (typeof(action) == TYPE_DICTIONARY and "events" in action):
					continue
				
				var item = tree_node.create_item(_root)
				item.set_metadata(COLUMN_DESCRIPTION, ainfo.name)
				if ainfo.desc != "":
					item.set_text(COLUMN_DESCRIPTION, ainfo.desc)
				else:
					item.set_text(COLUMN_DESCRIPTION, _SettingNameToHumanReadable(ainfo.name))
				item.set_selectable(0, false)
				
				for event in action.events:
					var column : int = -1
					var text : String = ""
					match event.get_class():
						"InputEventKey":
							if item.get_metadata(COLUMN_INPUT_KEY) == null:
								column = COLUMN_INPUT_KEY
								text = OS.get_scancode_string(
									event.scancode if event.scancode != 0 else event.physical_scancode
								)
						"InputEventMouseButton":
							if item.get_metadata(COLUMN_INPUT_MOUSEBUTTON) == null:
								column = COLUMN_INPUT_MOUSEBUTTON
								match event.button_index:
									BUTTON_LEFT:
										text = "Left"
									BUTTON_RIGHT:
										text = "Right"
									BUTTON_MIDDLE:
										text = "Middle"
									BUTTON_WHEEL_UP:
										text = "Wheel Up"
									BUTTON_WHEEL_DOWN:
										text = "Wheel Down"
									BUTTON_WHEEL_LEFT:
										text = "Wheel Left"
									BUTTON_WHEEL_RIGHT:
										text = "Wheel Right"
									BUTTON_XBUTTON1:
										text = "Xtra 1"
									BUTTON_XBUTTON2:
										text = "Xtra 2"
						"InputEventJoypadAxis":
							if item.get_metadata(COLUMN_INPUT_PAD_AXIS) == null:
								column = COLUMN_INPUT_PAD_AXIS
								match event.axis:
									JOY_ANALOG_LX:
										text = "LX"
									JOY_ANALOG_LY:
										text = "LY"
									JOY_ANALOG_RX:
										text = "RX"
									JOY_ANALOG_RY:
										text = "RY"
									JOY_ANALOG_L2:
										text = "L2"
									JOY_ANALOG_R2:
										text = "R2"
						"InputEventJoypadButton":
							if item.get_metadata(COLUMN_INPUT_PAD_BUTTON) == null:
								column = COLUMN_INPUT_PAD_BUTTON
								match event.button_index:
									JOY_XBOX_A:
										text = "XBox A"
									JOY_XBOX_B:
										text = "XBox B"
									JOY_XBOX_X:
										text = "XBox X"
									JOY_XBOX_Y:
										text = "XBox Y"
									JOY_SELECT:
										text = "Select"
									JOY_START:
										text = "Start"
									JOY_DPAD_UP:
										text = "D-Up"
									JOY_DPAD_DOWN:
										text = "D-Down"
									JOY_DPAD_LEFT:
										text = "D-Left"
									JOY_DPAD_RIGHT:
										text = "D-Right"
									JOY_L:
										text = "L1"
									JOY_L2:
										text = "L2"
									JOY_L3:
										text = "L3"
									JOY_R:
										text = "R1"
									JOY_R2:
										text = "R2"
									JOY_R3:
										text = "R3"
					
					if column >= 0:
						item.set_text(column, text)
						item.set_metadata(column, event)


func _ClearList() -> void:
	if _root == null:
		return
	
	var item : TreeItem = _root.get_children()
	if item != null:
		_root.remove_child(item)
		item.free()
		_ClearList()

func _UpdateColumnSpacing() -> void:
	tree_node.set_column_min_width(COLUMN_DESCRIPTION, rect_size.x * (1.0 - (input_name_spacing * 4)))
	tree_node.set_column_min_width(COLUMN_INPUT_KEY, rect_size.x * input_name_spacing)
	tree_node.set_column_min_width(COLUMN_INPUT_MOUSEBUTTON, rect_size.x * input_name_spacing)
	tree_node.set_column_min_width(COLUMN_INPUT_PAD_AXIS, rect_size.x * input_name_spacing)
	tree_node.set_column_min_width(COLUMN_INPUT_PAD_BUTTON, rect_size.x * input_name_spacing)


func _SetupTheme() -> void:
	var plist : Array = tree_node.get_property_list()
	for prop in plist:
		var prefix_idx : int = prop.name.find("/")
		if prefix_idx >= 0:
			var prefix : String = prop.name.substr(0, prefix_idx)
			var prop_name = prop.name.substr(prefix_idx + 1, prop.name.length() - (prefix_idx + 1))
			match prefix:
				"custom_colors":
					if not tree_node.has_color_override(prop_name):
						if tree_node.has_color(prop_name, _THEME_TYPE_NAME):
							# TODO: Check self AND tree_node for overrides?
							tree_node.add_color_override(
								prop_name,
								tree_node.get_color(prop_name, _THEME_TYPE_NAME)
							)
				"custom_constants":
					if not tree_node.has_constant_override(prop_name):
						if tree_node.has_constant(prop_name, _THEME_TYPE_NAME):
							tree_node.add_constant_override(
								prop_name,
								tree_node.get_constant(prop_name, _THEME_TYPE_NAME)
							)
				"custom_fonts":
					if not tree_node.has_font_override(prop_name):
						if tree_node.has_font(prop_name, _THEME_TYPE_NAME):
							tree_node.add_font_override(
								prop_name, 
								tree_node.get_font(prop_name, _THEME_TYPE_NAME)
							)
				"custom_icons":
					if not tree_node.has_icon_override(prop_name):
						if tree_node.has_icon(prop_name, _THEME_TYPE_NAME):
							tree_node.add_icon_override(
								prop_name,
								tree_node.get_icon(prop_name, _THEME_TYPE_NAME)
							)
				"custom_styles":
					if not tree_node.has_stylebox_override(prop_name):
						if tree_node.has_stylebox(prop_name, _THEME_TYPE_NAME):
							tree_node.add_stylebox_override(
								prop_name, 
								tree_node.get_stylebox(prop_name, _THEME_TYPE_NAME)
							)


func _ResetLastItem() -> void:
	if _last_selected.item != null:
		_last_selected.item.clear_custom_bg_color(_last_selected.column)

func _SetLastItem(item : TreeItem, column : int) -> void:
	_ResetLastItem()
	_last_selected.item = item
	_last_selected.column = column

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_focus_entered() -> void:
	if _root == null:
		return
	
	var item : TreeItem = _root.get_children()
	if item:
		item = item.get_next()
		if item:
			item.select(1)

func _on_focus_exited() -> void:
	if _last_selected.item != null:
		_last_selected.item.deselect(_last_selected.column)
	_on_nothing_selected()


func _on_item_activated() -> void:
	var item : TreeItem = tree_node.get_selected()
	if item:
		var column : int = tree_node.get_selected_column()
		var meta = item.get_metadata(column)
		_SetLastItem(item, column)
		if Engine.editor_hint:
			print("Input Mapping disabled in editor.")
		else:
			pass
		_on_nothing_selected()

func _on_item_selected() -> void:
	var item : TreeItem = tree_node.get_selected()
	if item:
		var column : int = tree_node.get_selected_column()
		if item.is_selectable(column):
			_SetLastItem(item, column)
		else:
			_on_nothing_selected()
	else:
		print("No Item")

func _on_nothing_selected() -> void:
	if _last_selected.item != null:
		_ResetLastItem()
	_last_selected.item = null
	_last_selected.column = -1