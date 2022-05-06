extends Node


# -----------------------------------------------------------------------------
# Export Variables
# -----------------------------------------------------------------------------
export var camera3d_path : NodePath = ""		setget set_camera3d_path
export var camera2d_path : NodePath = ""		setget set_camera2d_path



# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
var _camera3d_node : Spatial = null
var _camera2d_node : Camera2D = null

var _axis_strength : Vector2 = Vector2.ZERO
var _mod_key : Array = [false, false]

# -----------------------------------------------------------------------------
# Setters / Getters
# -----------------------------------------------------------------------------
func set_camera3d_path(p : NodePath) -> void:
	camera3d_path = p
	if camera3d_path == "":
		_camera3d_node = null
	else:
		var cn = get_node_or_null(camera3d_path)
		if cn and cn.has_method("move"):
			_camera3d_node = cn

func set_camera2d_path(p : NodePath) -> void:
	camera2d_path = p
	if camera2d_path == "":
		_camera2d_node = null
	else:
		var cn = get_node_or_null(camera2d_path)
		if cn and cn is Camera2D:
			_camera2d_node = cn


# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	set_camera2d_path(camera2d_path)
	set_camera3d_path(camera3d_path)

func _unhandled_input(event) -> void:
	if _camera3d_node == null or _camera2d_node == null:
		return
	
	if event is InputEventMouseMotion:
		if _mod_key[0]:
			_camera3d_node.move_ground(-event.relative)
		elif _mod_key[1]:
			_camera3d_node.orbit(event.relative.x, event.relative.y)
	elif event is InputEventJoypadMotion:
		pass
	elif event is InputEventMouseButton:
		match event.button_index:
			BUTTON_RIGHT:
				_mod_key[0] = event.pressed or Input.is_action_pressed("game_shift")
			BUTTON_MIDDLE:
				_mod_key[1] = event.pressed or Input.is_action_pressed("game_ctrl")
			BUTTON_WHEEL_UP:
				print("Wheel Up!")
				_camera3d_node.zoom_in()
			BUTTON_WHEEL_DOWN:
				print("Wheel Down")
				_camera3d_node.zoom_out()
	elif event is InputEventAction:
		match event.action:
			"game_up":
				if event.pressed:
					_axis_strength.y = 0.0 if Input.is_action_pressed("game_down") else -1.0
				else:
					_axis_strength.y = 1.0 if Input.is_action_pressed("game_down") else 0.0
			"game_down":
				if event.pressed:
					_axis_strength.y = 0.0 if Input.is_action_pressed("game_up") else 1.0
				else:
					_axis_strength.y = -1.0 if Input.is_action_pressed("game_up") else 0.0
			"game_left":
				if event.pressed:
					_axis_strength.x = 0.0 if Input.is_action_pressed("game_right") else -1.0
				else:
					_axis_strength.x = 1.0 if Input.is_action_pressed("game_right") else 0.0
			"game_right":
				if event.pressed:
					_axis_strength.x = 0.0 if Input.is_action_pressed("game_left") else 1.0
				else:
					_axis_strength.x = -1.0 if Input.is_action_pressed("game_left") else 0.0
			"game_shift":
				_mod_key[0] = event.pressed
			"game_ctrl":
				_mod_key[1] = event.pressed
		
	#if _mod_key[0]:
	#	_HandleShiftStateEvents(event)

# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------
func _HandleShiftStateEvents(event) -> void:
	pass

