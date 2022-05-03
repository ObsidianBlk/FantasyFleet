extends Object
tool
class_name VectorHex

# Based on information at...
# https://www.redblobgames.com/grids/hexagons/

# -------------------------------------------------------------------------
# Constants and ENUMs
# -------------------------------------------------------------------------
const SQRT3 : float = sqrt(3)
const NEIGHBOR_OFFSET : Array = [
	Vector3(0, -1, 1),
	Vector3(-1, 0, 1),
	Vector3(-1, 1, 0),
	Vector3(0, 1, -1),
	Vector3(1, 0, -1),
	Vector3(1, -1, 0)
]

enum ORIENTATION {Pointy=0, Flat=1}

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var c : Vector3 = Vector3.ZERO


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _init(value = null, point_is_spacial : bool = false) -> void:
	if typeof(value) == TYPE_OBJECT and value.has_method("is_valid") and value.is_valid():
		c = value.qrs
	elif typeof(value) == TYPE_VECTOR3:
		c = value
	elif typeof(value) == TYPE_VECTOR2:
		if point_is_spacial:
			from_point(value)
		else:
			c = Vector3(value.x, -value.x -value.y, value.y)

func _get(property : String):
	match property:
		"q":
			return c.x
		"r":
			return c.z
		"s":
			return c.y
		"qrs":
			return c
		"qr":
			return Vector2(c.x, c.z)


func _set(property : String, value) -> bool:
	var success : bool = true
	
	match property:
		"q":
			if typeof(value) == TYPE_REAL:
				c.x = value
			else : success = false
		"r":
			if typeof(value) == TYPE_REAL:
				c.z = value
			else : success = false
		"s":
			if typeof(value) == TYPE_REAL:
				c.y = value
			else : success = false
		"qrs":
			if typeof(value) == TYPE_VECTOR3:
				c = value
			elif typeof(value) == TYPE_OBJECT and value.has_method("round_hex"):
				c.x = value.q
				c.z = value.r
				c.y = value.s
			else:
				success = false
		"qr":
			if typeof(value) == TYPE_VECTOR2:
				c.x = value.x
				c.z = value.y
				c.y = (-c.x)-c.z
	
	if success:
		property_list_changed_notify()
	return success


func _get_property_list() -> Array:
	var props : Array = [
		{
			name = "q",
			type = TYPE_REAL,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "r",
			type = TYPE_REAL,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "s",
			type = TYPE_REAL,
			usage = PROPERTY_USAGE_DEFAULT
		},
	]
	return props

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func is_valid() -> bool:
	return c.x + c.y + c.z == 0

func round_hex() -> void:
	var q = floor(c.x)
	var r = floor(c.z)
	var s = floor(c.y)
	
	var dq = c.x - q
	var dr = c.z - r
	var ds = c.y - s
	
	if dq > dr and dq > ds:
		q = -r -s
	elif dr > ds:
		r = -q -s
	else:
		s = -r -s
	
	c.x = q
	c.z = r
	c.y = s


func distance_to(vh : VectorHex) -> float:
	if is_valid() and vh != null and vh.is_valid():
		var subc : Vector3 = c - vh.qrs
		return (abs(subc.x) + abs(subc.y) + abs(subc.z)) * 0.5
	return 0.0

func to_point(orientation : int = ORIENTATION.Pointy) -> Vector2:
	var x : float = 0.0
	var y : float = 0.0
	if is_valid():
		match orientation:
			ORIENTATION.Pointy:
				x = (SQRT3 * c.x) + ((SQRT3/2.0) * c.z)
				y = (2/3) * c.z
			ORIENTATION.Flat:
				x = (2/3) * c.x
				y = ((SQRT3/2) * c.x) + (SQRT3 * c.z)
	return Vector2(x,y)

func from_point(point : Vector2, orientation : int = ORIENTATION.Pointy) -> void:
	if not is_valid():
		return
	
	var fq : float = 0.0
	var fr : float = 0.0
	match orientation:
		ORIENTATION.Pointy:
			fq = ((SQRT3/3) * point.x) - ((1/3) * point.y)
			fr = (2/3) * point.y
		ORIENTATION.Flat:
			fq = (2/3) * point.x
			fr = ((-1/3) * point.x) + ((SQRT3/3) * point.y)
	var fs : float = -fq -fr
	c = Vector3(fq, fs, fr)
	round_hex()

func get_neighbor(dir : int, amount : int = 1) -> VectorHex:
	if is_valid() and amount > 0:
		if dir >= 0 and dir < NEIGHBOR_OFFSET.size():
			var vh : VectorHex = get_script().new(c + (NEIGHBOR_OFFSET[dir] * float(amount)))
			return vh
	return null
	
