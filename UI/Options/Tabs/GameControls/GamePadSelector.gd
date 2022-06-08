extends MenuButton

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var joypads : Array = []

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	Input.connect("joy_connection_changed", self, "_on_joypad_connection_changed")
	EIM.connect("active_joypad_changed", self, "_on_active_joypad_changed")
	var popup : PopupMenu = get_popup()
	popup.connect("index_pressed", self, "_on_index_pressed", [popup])
	_BuildGamepadList()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _BuildGamepadList() -> void:
	var menu : PopupMenu = get_popup()
	menu.clear()
	
	var joypads : Array = EIM.get_joypad_list()
	for padid in range(0, joypads.size()):
		var pad = joypads[padid]
		menu.add_item(pad.name, padid)
		menu.set_item_metadata(padid, pad.id)
		if EIM.get_active_joypad_id() == pad.id:
			text = pad.name


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_index_pressed(idx : int, popup : PopupMenu) -> void:
	var pad_id : int = popup.get_item_metadata(idx)
	EIM.set_active_joypad_id(pad_id)

func _on_joypad_connection_changed(device : int, connected : bool) -> void:
	_BuildGamepadList()
	if not connected and EIM.get_active_joypad_id() == device:
		if not EIM.set_joypad_to_first_identified():
			text = "No Connected Gamepads"

func _on_active_joypad_changed(device : int, device_name : String) -> void:
	text = device_name
