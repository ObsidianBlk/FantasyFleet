extends Control

# -------------------------------------------------------------------------
# Signal
# -------------------------------------------------------------------------
signal key_action_redefined(event)

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export (Array, Array, String) var exposed_inputs : Array = []

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _focused_action = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	set_process_input(false)
	print("Prebuild count: ", get_children().size())
	_BuildInputList()
	print("Postbuild count: ", get_children().size())


func _input(event) -> void:
	if _focused_action == null:
		return
	
	if event.is_action_pressed("ui_cancel"):
		print("Input key canceled")
		_focused_action = null
		set_process_input(false)
	
	if _focused_action is InputEventKey and event is InputEventKey:
		_focused_action.scancode = event.scancode
		_focused_action.physical_scancode = event.physical_scancode
		_focused_action = null
		set_process_input(false)
		emit_signal("key_action_redefined", event)


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _BuildInputList() -> void:
	for inp in exposed_inputs:
		if InputMap.has_action(inp[0]):
			var actions = InputMap.get_action_list(inp[0])
			if actions.size() > 0:
				var hbc : HBoxContainer = HBoxContainer.new()
				for action in actions:
					if action is InputEventKey:
						var btn : Button = Button.new()
						if action.scancode > 0:
							btn.text = OS.get_scancode_string(action.scancode)
						elif action.physical_scancode > 0:
							btn.text = OS.get_scancode_string(action.physical_scancode)
						else:
							printerr("InputEventKey action found but no valid scancode.")
						if btn.text != "":
							btn.rect_min_size.x = 96.0
							btn.connect("pressed", self, "_on_input_change_requested", [action, btn])
							hbc.add_child(btn)
				var buff : Control = Control.new()
				buff.size_flags_horizontal = SIZE_EXPAND_FILL
				hbc.add_child(buff)
				
				var lbl : Label = Label.new()
				lbl.text = inp[1]
				hbc.add_child(lbl)
				
				add_child(hbc)


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_input_change_requested(action, btn : Button) -> void:
	if _focused_action != null:
		return
	
	_focused_action = action
	set_process_input(true)

