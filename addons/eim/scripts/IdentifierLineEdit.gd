tool
extends LineEdit



# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	connect("text_changed", self, "_on_text_changed")


# -----------------------------------------------------------------------------
# Handler Methods
# -----------------------------------------------------------------------------
func _on_text_changed(new_text : String) -> void:
	var mode : String = "focus" if has_focus() else "normal"
	if new_text != "" and not new_text.is_valid_identifier():
		var sb : StyleBox = null
		if has_stylebox("invalid_" + mode, "EIM_LineEdit"):
			sb = get_stylebox("invalid_" + mode, "EIM_LineEdit")
		add_stylebox_override(mode, sb)
	else:
		add_stylebox_override(mode, null)
