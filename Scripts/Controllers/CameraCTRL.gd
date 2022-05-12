extends Node


# -----------------------------------------------------------------------------
# Export Variables
# -----------------------------------------------------------------------------
export var camera3d_path : NodePath = ""		setget set_camera3d_path



# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
var _camera3d_node : Spatial = null


var _L_axis_strength : Vector2 = Vector2.ZERO
var _R_axis_strength : Vector2 = Vector2.ZERO
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

# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	set_camera3d_path(camera3d_path)
	Input.connect("joy_connection_changed", self, "_on_joy_changed")

func _process(_delta : float) -> void:
	_ReadJoypadAxis()
	if _camera3d_node:
		if _L_axis_strength.length_squared() > 0.0:
			_camera3d_node.move_ground(-_L_axis_strength, Game.view_mode == Game.VIEW.MODE_2D)
		if _R_axis_strength.length_squared() > 0.0:
			_camera3d_node.orbit(_R_axis_strength.x, _R_axis_strength.y)

func _unhandled_input(event) -> void:
	if _camera3d_node == null:
		return
	
	if event is InputEventMouseMotion:
		if _mod_key[0]:
			_camera3d_node.move_ground(-event.relative, Game.view_mode == Game.VIEW.MODE_2D)
		elif _mod_key[1]:
			_camera3d_node.orbit(event.relative.x, event.relative.y)
		Game.bounce_input(event)
	#elif event is InputEventJoypadMotion:  # NOTE: Working with joypad axii here cause joypad disconnection
	#	pass#print("Joyous Motion!")		#   Is this a bug?
	elif event is InputEventMouseButton:
		match event.button_index:
			BUTTON_RIGHT:
				_mod_key[0] = event.pressed or Input.is_action_pressed("game_shift")
			BUTTON_MIDDLE:
				_mod_key[1] = event.pressed or Input.is_action_pressed("game_ctrl")
			BUTTON_WHEEL_UP:
				_camera3d_node.zoom_in()
			BUTTON_WHEEL_DOWN:
				_camera3d_node.zoom_out()
	else:
		if event.is_action("game_up"):
			if event.is_action_pressed("game_up"):
				_L_axis_strength.y = 0.0 if Input.is_action_pressed("game_down") else 1.0
			elif event.is_action_released("game_up"):
				_L_axis_strength.y = -1.0 if Input.is_action_pressed("game_down") else 0.0
		elif event.is_action("game_down"):
			if event.is_action_pressed("game_down"):
				_L_axis_strength.y = 0.0 if Input.is_action_pressed("game_up") else -1.0
			elif event.is_action_released("game_down"):
				_L_axis_strength.y = 1.0 if Input.is_action_pressed("game_up") else 0.0
		elif event.is_action("game_left"):
			if event.is_action_pressed("game_left"):
				_L_axis_strength.x = 0.0 if Input.is_action_pressed("game_right") else 1.0
			elif event.is_action_released("game_left"):
				_L_axis_strength.x = -1.0 if Input.is_action_pressed("game_right") else 0.0
		elif event.is_action("game_right"):
			if event.is_action_pressed("game_right"):
				_L_axis_strength.x = 0.0 if Input.is_action_pressed("game_left") else -1.0
			elif event.is_action_released("game_right"):
				_L_axis_strength.x = 1.0 if Input.is_action_pressed("game_left") else 0.0
		elif event.is_action("game_shift"):
			if event.is_action_pressed("game_shift"):
				_mod_key[0] = true
			elif event.is_action_released("game_shift"):
				_mod_key[0] = false
		elif event.is_action("game_ctrl"):
			if event.is_action_pressed("game_ctrl"):
				_mod_key[1] = true
			elif event.is_action_released("game_ctrl"):
				_mod_key[1] = false
		
	#if _mod_key[0]:
	#	_HandleShiftStateEvents(event)

# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------
func _ReadJoypadAxis() -> void:
	var x = Input.get_joy_axis(Game.active_joypad_id, JOY_AXIS_0)
	var y = Input.get_joy_axis(Game.active_joypad_id, JOY_AXIS_1)
	if abs(x) > 0.4 or abs(y) > 0.4: # TODO: Make dead zone more configurable
		_L_axis_strength = Vector2(x, y)
	elif abs(x) < 0.1 and abs(y) < 0.1:
		_L_axis_strength = Vector2.ZERO
	x = Input.get_joy_axis(Game.active_joypad_id, JOY_AXIS_2)
	y = Input.get_joy_axis(Game.active_joypad_id, JOY_AXIS_3)
	if abs(x) > 0.4 or abs(y) > 0.4:
		_R_axis_strength = Vector2(x, y)
	elif abs(x) < 0.1 and abs(y) < 0.1:
		_R_axis_strength = Vector2.ZERO

# -----------------------------------------------------------------------------
# Handler Methods
# -----------------------------------------------------------------------------
func _on_joy_changed(device_id : int, connected : bool) -> void:
	print ("Connected, Device ", device_id, ": ", connected)
