extends Resource
tool
class_name Entity

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal position_changed(new_pos)
signal move(dir, amount)

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _position : Vector3 = Vector3.ZERO

var _deferred_emit_list : Dictionary = {}
var _deferred_emit : bool = false

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _get(property : String):
	match property:
		"position":
			return _position
	
	return null


func _set(property : String, value) -> bool:
	var success : bool = true
	
	match property:
		"position":
			if value is VectorHex:
				if value.is_valid():
					_position = value.qrs
					_DeferredEmit("position_changed")
				else : success = false
			elif typeof(value) == TYPE_VECTOR3:
				var vh : VectorHex = VectorHex.new(value)
				if vh.is_valid():
					_position = vh.qrs
					_DeferredEmit("position_changed")
				else : success = false
			elif typeof(value) == TYPE_VECTOR2:
				var vh : VectorHex = VectorHex.new(value, true)
				_position = vh.qrs
				_DeferredEmit("position_changed")
			else:
				success = false
		_:
			success = false
	
	if success:
		property_list_changed_notify()
	return success


func _get_property_list() -> Array:
	var props : Array = [
		{
			name="position",
			type=TYPE_VECTOR3,
			usage=PROPERTY_USAGE_DEFAULT
		}
	]
	return props

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _DeferredEmit(signal_name : String, args : Array = [null]) -> void:
	if not signal_name in _deferred_emit_list:
		_deferred_emit_list[signal_name] = args
	if not _deferred_emit:
		_deferred_emit = true
		call_deferred("_FinishDeferredEmit")

func _FinishedDeferredEmit() -> void:
	_deferred_emit = false
	for sig_name in _deferred_emit_list.keys():
		callv("emit_signal", _deferred_emit_list[sig_name])

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func move(dir : int, amount : int) -> void:
	emit_signal("move", dir, amount)

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

