extends Resource
tool
class_name Entity

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal entity_freed()
signal position_changed(new_pos)
signal move(dir, amount)

# -------------------------------------------------------------------------
# "Export" Variables
# -------------------------------------------------------------------------
var _uuid : String = ""
var _hex : HexCell = HexCell.new()
var _blocking_view : bool = false
var _blocking_cell : bool = false

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _get(property : String):
	match property:
		"uuid":
			return _uuid
		"hex":
			return _hex
		"qrs":
			return _hex.qrs
		"blocking_view":
			return _blocking_view
		"blocking_cell":
			return _blocking_cell
	
	return null


func _set(property : String, value) -> bool:
	var success : bool = true
	
	match property:
		"uuid":
			if typeof(value) == TYPE_STRING and _uuid == "":
				_uuid = value
			else : success = false
		"hex":
			if value is HexCell:
				if value.is_valid():
					_hex.qrs = value.qrs
					Utils.call_deferred_once("emit_signal", self, ["position_changed"])
				else : success = false
			elif typeof(value) == TYPE_VECTOR3:
				_hex.qrs = value
				if not _hex.is_valid():
					_hex.round_hex()
				Utils.call_deferred_once("emit_signal", self, ["position_changed"])
			elif typeof(value) == TYPE_VECTOR2:
				_hex.qr = value
				Utils.call_deferred_once("emit_signal", self, ["position_changed"])
			else : success = false
		"qrs":
			if typeof(value) == TYPE_VECTOR3:
				_hex.qrs = value
				if not _hex.is_valid():
					_hex.round_hex()
				Utils.call_deferred_once("emit_signal", self, ["position_changed"])
		"blocking_view":
			if typeof(value) == TYPE_BOOL:
				_blocking_view = value
			else : success = false
		"blocking_cell":
			if typeof(value) == TYPE_BOOL:
				_blocking_cell = value
			else : success = false
		_:
			success = false
	
	if success:
		property_list_changed_notify()
	return success


func _get_property_list() -> Array:
	var props : Array = [
		{
			name = "uuid",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "hex",
			type = TYPE_OBJECT,
			usage = PROPERTY_USAGE_NO_INSTANCE_STATE
		},
		{
			name = "qrs",
			type = TYPE_VECTOR3,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "blocking_view",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "blocking_cell",
			type = TYPE_BOOL,
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
func free() -> void:
	emit_signal("entity_freed")
	.free()

func move(dir : int, amount : int) -> void:
	emit_signal("move", dir, amount)

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

