extends PopupPanel


# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal input_monitor_canceled()
signal input_captured(event)

# -------------------------------------------------------------------------
# Constants and ENUMs
# -------------------------------------------------------------------------
enum IETYPE {Key=0, Mouse=1, JoyAxis=2, JoyButton=3, JoyCombo=4}

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export (IETYPE) var input_focus : int = IETYPE.Key

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _input(event) -> void:
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.is_pressed():
			emit_signal("input_monitor_canceled")
			accept_event()
			return
	match input_focus:
		IETYPE.Key:
			if event is InputEventKey and event.is_pressed() and not event.is_echo():
				accept_event()
				emit_signal("input_captured", event)
		IETYPE.Mouse:
			if event is InputEventMouseButton and event.is_pressed() and not event.is_echo():
				accept_event()
				emit_signal("input_captured", event)
		IETYPE.JoyAxis:
			if event is InputEventJoypadMotion:
				accept_event()
				emit_signal("input_captured", event)
		IETYPE.JoyButton:
			if event is InputEventJoypadButton and event.is_pressed() and not event.is_echo():
				accept_event()
				emit_signal("input_captured", event)
		IETYPE.JoyCombo:
			if (event is InputEventJoypadButton and event.is_pressed() and not event.is_echo()) or (event is InputEventJoypadMotion):
				accept_event()
				emit_signal("input_captured", event)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------



# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------


