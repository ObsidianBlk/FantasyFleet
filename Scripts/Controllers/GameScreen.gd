extends ColorRect

# -----------------------------------------------------------------------------
# Signals
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
var toggle_ready : bool = true

# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	Game.connect("view_mode_changed", self, "_on_view_mode_changed")
	_on_view_mode_changed(Game.view_mode)

func _unhandled_input(event) -> void:
	if event.is_action_pressed("game_view_toggle") and toggle_ready:
		toggle_ready = false
		match Game.view_mode:
			Game.VIEW.MODE_2D:
				Game.view_mode = Game.VIEW.MODE_3D
			Game.VIEW.MODE_3D:
				Game.view_mode = Game.VIEW.MODE_2D
	elif event.is_action_released("game_view_toggle"):
		toggle_ready = true

# -----------------------------------------------------------------------------
# Handler Methods
# -----------------------------------------------------------------------------
func _on_view_mode_changed(mode : int) -> void:
	material.set_shader_param("view2d_active", mode == Game.VIEW.MODE_2D)
