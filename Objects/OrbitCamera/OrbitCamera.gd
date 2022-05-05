extends Spatial

# -----------------------------------------------------------------------------
# Export Variables
# -----------------------------------------------------------------------------
export var current : bool = false									setget set_current
export (int, LAYERS_3D_PHYSICS) var collision_mask : int = 1		setget set_collision_mask
export (float, 1.0, 180.0, 0.1) var fov : float = 60.0				setget set_fov
export var min_zoom : float = 0.01
export var max_zoom : float = 1000.0
export var zoom_step : float = 2.0
export var pitch_degree_max : float = 45.0
export var pitch_degree_min : float = -45.0
export var smooth_tracking : bool = false
export var tracking_duration : float = 0.25
export var tracking_max_distance : float = 5.0

export var sensitivity : Vector2 = Vector2(0.2, 0.2)

export var target_node_path : NodePath = ""

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
var _target_node : Spatial = null
var _last_target_pos : Vector3 = Vector3.ZERO
var _tracking_tween : Tween = null

# -----------------------------------------------------------------------------
# Onready Variables
# -----------------------------------------------------------------------------
onready var _camera_node : ClippedCamera = $Arm/ClippedCamera
onready var _arm_node : Spatial = $Arm

# -----------------------------------------------------------------------------
# Setters / Getters
# -----------------------------------------------------------------------------
func set_current(c : bool) -> void:
	current = c
	if _camera_node:
		_camera_node.current = c


func set_collision_mask(m : int) -> void:
	if m >= 0:
		collision_mask = m
		if _camera_node:
			_camera_node.collision_mask = collision_mask

func set_fov(f : float) -> void:
	if f >= 1.0 and f <= 180.0:
		fov = f
		if _camera_node:
			_camera_node.fov = fov

func set_target_node_path(tnp : NodePath) -> void:
	target_node_path = tnp
	if target_node_path == "":
		_target_node = null
	else:
		var tn = get_node(target_node_path)
		if tn is Spatial:
			_target_node = tn

func set_smooth_tracking(st : bool) -> void:
	smooth_tracking = st
	if smooth_tracking and _tracking_tween == null:
		_tracking_tween = Tween.new()
		add_child(_tracking_tween)
	elif not smooth_tracking and _tracking_tween != null:
		_tracking_tween.stop_all()
		remove_child(_tracking_tween)
		_tracking_tween = null

# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------
func _ready() -> void:
	set_current(current)
	set_collision_mask(collision_mask)
	set_fov(fov)
	set_target_node_path(target_node_path)

func _process(_delta) -> void:
	if _target_node != null:
		if _target_node.global_transform.origin != _last_target_pos:
			_last_target_pos = _target_node.global_transform.origin
			_TrackToPosition(_last_target_pos)

# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------
func _TrackToPosition(pos : Vector3) -> void:
	if smooth_tracking:
		var duration = max(0, tracking_duration)
		if tracking_max_distance > 0.0:
			var dist = min(max(0, tracking_max_distance), pos.distance_to(global_transform.origin))
			duration = tracking_duration * (dist / tracking_max_distance)
		if duration > 0:
			_tracking_tween.stop_all()
			_tracking_tween.interpolate_property(
				self, "global_transform.origin",
				global_transform.origin, pos,
				duration,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			_tracking_tween.start()
			return
	global_transform.origin = pos

# -----------------------------------------------------------------------------
# Public Methods
# -----------------------------------------------------------------------------
func set_target(target : Spatial) -> void:
	_target_node = target
	if _target_node == null:
		target_node_path = ""
	else:
		target_node_path = get_path_to(_target_node)

func move(delta_pos : Vector3) -> void:
	_TrackToPosition(global_transform.origin + delta_pos)

func orbit(yaw : float, pitch : float) -> void:
	rotation.y = wrapf(rotation.y - (yaw * sensitivity.x), 0.0, TAU)
	rotation.x = clamp(rotation.x - (pitch * sensitivity.y), deg2rad(pitch_degree_min), deg2rad(pitch_degree_max))

func zoom(amount : float) -> void:
	var y = _arm_node.transform.origin.y
	_arm_node.transform.origin.y = max(max_zoom, min(min_zoom, y - amount))

func zoom_in() -> void:
	zoom(-zoom_step)

func zoom_out() -> void:
	zoom(zoom_step)
