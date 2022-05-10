extends ColorRect

# -----------------------------------------------------------------------------
# Export Variables
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
var toggle_ready : bool = true
var view_mode_2d : bool = true

# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------

func _unhandled_input(event) -> void:
	if event.is_action_pressed("game_view_toggle") and toggle_ready:
		toggle_ready = false
		view_mode_2d = not view_mode_2d
		material.set_shader_param("view2d_active", view_mode_2d)
	elif event.is_action_released("game_view_toggle"):
		toggle_ready = true

