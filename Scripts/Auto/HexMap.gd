extends Node

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal map_data_changed(hmd)

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var hex_map_data : Resource = null			setget set_hex_map_data

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _regions = {}

var _rng : RandomNumberGenerator = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_hex_map_data (hmd : Resource) -> void:
	if hmd is HexMapData:
		hex_map_data = hmd
		emit_signal("map_data_changed", hex_map_data)

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_SetRandomize()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _SetRandomize() -> void:
	if _rng == null:
		_rng = RandomNumberGenerator.new()
		_rng.randomize()

func _GetRandomRegionID(attempt : int = 10) -> int:
	_SetRandomize()
	var id : int = _rng.randi()
	if id in _regions:
		if attempt > 0:
			return _GetRandomRegionID(attempt - 1)
		return -1
	return id

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func add_area_region(origin : HexCell, radius) -> int:
	var id : int = _GetRandomRegionID()
	if id < 0:
		return -1
	_regions[id] = origin.get_region(radius)
	return id

func add_ring_region(origin : HexCell, radius) -> int:
	var id : int = _GetRandomRegionID()
	if id < 0:
		return -1
	_regions[id] = origin.get_ring(radius)
	return id

func remove_region(id : int) -> void:
	if id in _regions:
		_regions.erase(id)

func remove_all_regions() -> void:
	_regions.clear()

func get_region(id : int) -> Array:
	if id in _regions:
		return _regions[id]
	return []

func get_region_ids() -> Array:
	return _regions.keys()

func get_region_count() -> int:
	return _regions.keys().size()

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

