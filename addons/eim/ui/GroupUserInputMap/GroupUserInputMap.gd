tool
extends Tree

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const COLUMN_DESCRIPTION : int = 0
const COLUMN_INPUT_KEY : int = 1
const COLUMN_INPUT_MOUSEBUTTON : int = 2
const COLUMN_INPUT_PAD_AXIS : int = 3
const COLUMN_INPUT_PAD_BUTTON : int = 4 

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var group_name : String		setget set_group_name

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _root : TreeItem = null

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


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	columns = 5
	set_group_name(group_name, true)
	connect("item_activated", self, "_on_item_activated")


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _SettingNameToHumanReadable(setting_name : String) -> String:
	var last_idx : int = setting_name.find_last("/")
	if last_idx >= 0:
		setting_name = setting_name.substr(0, last_idx + 1)
	return setting_name.replace("_", " ").capitalize()

func _BuildList() -> void:
	if group_name.is_valid_identifier():
		var alist : Array = EIM.get_group_action_list(group_name)
		if alist.size() > 0:
			if _root == null:
				_root = create_item()
				set_hide_root(true)
			else:
				_ClearList()
			
			for ainfo in alist:
				var action = ProjectSettings.get_setting(ainfo.name)
				if not (typeof(action) == TYPE_DICTIONARY and "events" in action):
					continue
				
				var item = create_item(_root)
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
						item.set_cell_mode(column, TreeItem.CELL_MODE_CUSTOM)
						item.set_custom_as_button(column, true)
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

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_item_activated() -> void:
	var item : TreeItem = get_selected()
	if item:
		var column : int = get_selected_column()
		var meta = item.get_metadata(column)
		print("Meta: ", meta)
