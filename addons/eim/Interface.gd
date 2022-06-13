tool
extends Control

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

onready var proj_line_node : LineEdit = $UnenabledUI/VBC/Project/LineEdit
onready var proj_btn_node : Button = $UnenabledUI/VBC/Project/Enable

onready var config_section_node : LineEdit = $EnabledUI/VBC/MiscEIMConfig/ConfSection/LineEdit

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	EIM.connect("initialized", self, "_on_eim_initialized")
	EIM.connect("deconstructed", self, "_on_eim_deconstructed")
	_CheckUI()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _CheckUI() -> void:
	if EIM.get_project_name() != "":
		_on_eim_initialized("")
	else:
		_on_eim_deconstructed()

func _UpdateSettings() -> void:
	config_section_node.text = EIM.get_config_section()

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

func _on_eim_initialized(proj_name : String) -> void:
	if unenabledui_node and ui_node:
		unenabledui_node.visible = false
		ui_node.visible = true
		_UpdateSettings()

func _on_eim_deconstructed() -> void:
	if unenabledui_node and ui_node:
		ui_node.visible = false
		unenabledui_node.visible = true

func _on_Project_LineEdit_text_changed(new_text : String) -> void:
	proj_btn_node.disabled = (new_text == "" or not new_text.is_valid_identifier())

func _on_ConfSection_text_changed(new_text : String) -> void:
	if new_text == "" or not new_text.is_valid_identifier():
		var mode : String = "focus" if config_section_node.has_focus() else "normal"
		var sb : StyleBox = null
		if config_section_node.has_stylebox("invalid_" + mode, "EIM_LineEdit"):
			sb = config_section_node.get_stylebox("invalid_" + mode, "EIM_LineEdit")
		config_section_node.add_stylebox_override(mode, sb)

func _on_Project_Enable_pressed() -> void:
	if proj_line_node.text == "" or not proj_line_node.text.is_valid_identifier():
		return # Technically, this should never be a worry, but better safe than sorry.
	EIM.initialize_eim(proj_line_node.text, true)
	#_InitializeEIM(proj_line_node.text, true)
	#_on_eim_initialized("")

func _on_disable_eim_pressed():
	EIM.deconstruct_eim()
	#_on_eim_deconstructed()
	#_DeconstructEIM()

func _on_save_project_settings_pressed():
	if config_section_node.text.is_valid_identifier():
		EIM.set_config_section(config_section_node.text)
	else:
		config_section_node.text = EIM.get_config_section()
	ProjectSettings.save()

