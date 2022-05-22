tool
extends Container

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const DEFAULT_ACTIONS : PoolStringArray = PoolStringArray([
	"input/ui_accept",
	"input/ui_cancel",
	"input/ui_down",
	"input/ui_end",
	"input/ui_focus_next",
	"input/ui_focus_prev",
	"input/ui_home",
	"input/ui_left",
	"input/ui_page_down",
	"input/ui_page_up",
	"input/ui_right",
	"input/ui_select",
	"input/ui_up"
])


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var unenabledui_node : Control = $UnenabledUI
onready var ui_node : Control = $EnabledUI

onready var proj_line_node : LineEdit = $UnenabledUI/Project/LineEdit
onready var proj_btn_node : Button = $UnenabledUI/Project/Enable

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	EIM.connect("eim_initialized", self, "_on_eim_initialized")
	EIM.connect("eim_deactivated", self, "_on_eim_deactivated")
	_CheckUI()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _CheckUI() -> void:
	if EIM.initialize():
		_on_eim_initialized("")
	else:
		_on_eim_deactivated()



func _InitializeEIM(proj_name : String, initialize_default_inputs : bool) -> void:
	if not proj_name.is_valid_identifier():
		return
	if ProjectSettings.has_setting(EIM.SETTINGS_NAME_VAR):
		printerr("WARNING: EIM already appears initialized, or required custom setting name created outside EIM control.")
		return
	
	if ProjectSettings.save_custom("res://project_original.godot") != OK:
		printerr("EIM ERROR: Failed to save \"project_original.godot\" file. Canceling EIM initialization.")
		return
	
	ProjectSettings.set_setting(EIM.SETTINGS_NAME_VAR, proj_name)
	ProjectSettings.set_setting(proj_name + EIM.PROP_EI_GROUP_LIST, [])
	if EIM.initialize():
		if initialize_default_inputs:
			if EIM.set_group("UI_Actions", false):
				for action_name in DEFAULT_ACTIONS:
					EIM.add_action_to_group("UI_Actions", action_name)
		ProjectSettings.save()


func _DeconstructEIM(force : bool = false) -> void:
	var proj_name = EIM.get_project_name()
	if not force and (proj_name == "" or not proj_name.is_valid_identifier()):
		printerr("EIM ERROR: Deconstruction of EIM failed. Project name invalid.")
		return
	
	var glist = EIM.get_group_list()
	for group_name in glist:
		EIM.drop_group(group_name)
	ProjectSettings.set_setting(proj_name + EIM.PROP_EI_GROUP_LIST, null)
	ProjectSettings.set_setting(EIM.SETTINGS_NAME_VAR, null)
	EIM.initialize()
	ProjectSettings.save()

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_eim_initialized(proj_name : String) -> void:
	unenabledui_node.visible = false
	ui_node.visible = true

func _on_eim_deactivated() -> void:
	ui_node.visible = false
	unenabledui_node.visible = true

func _on_Project_LineEdit_text_changed(new_text : String) -> void:
	proj_btn_node.disabled = (new_text != "" and new_text.is_valid_identifier())


func _on_Project_Enable_pressed() -> void:
	if proj_line_node.text == "" or not proj_line_node.text.is_valid_identifier():
		return # Technically, this should never be a worry, but better safe than sorry.
	_InitializeEIM(proj_line_node.text, true)
	_CheckUI()


