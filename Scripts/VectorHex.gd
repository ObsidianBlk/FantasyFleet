extends Object
class_name VectorHex

# Based on information at...
# https://www.redblobgames.com/grids/hexagons/


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var c : Vector3 = Vector3.ZERO


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------

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
			if value is VectorHex:
				c.x = value.q
				c.z = value.r
				c.y = value.s
			elif typeof(value) == TYPE_VECTOR3:
				c = value
			else:
				success = false
		"qr":
			if typeof(value) == TYPE_VECTOR2:
				c.x = value.x
				c.z = value.z
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
func _ShiftedVectorHex(v : Vector3) -> VectorHex:
	var vh : VectorHex = VectorHex.new()
	vh.qrs = c + v
	return vh

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------

func distance_to(vh : VectorHex) -> float:
	var subc : Vector3 = c - vh.qrs
	return (abs(subc.x) + abs(subc.y) + abs(subc.z)) * 0.5




