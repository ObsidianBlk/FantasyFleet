extends Resource
class_name HexMapData

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const HEX_POINTS : Array = [
	Vector2(0, -.5),
	Vector2(-.5, -(1.0/3.0)),
	Vector2(-.5, (1.0/3.0)),
	Vector2(0, .5),
	Vector2(.5, (1.0/3.0)),
	Vector2(.5, -(1.0/3.0))
]

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _cells : Dictionary = {}
var _entities : Dictionary = {}

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _get(property : String):
	match property:
		_:
			pass
	
	return null


func _set(property : String, value) -> bool:
	var success : bool = true
	
	match property:
		_:
			success = false
	
	if success:
		property_list_changed_notify()
	return success


func _get_property_list() -> Array:
	var props : Array = [
		
	]
	return props


# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _ListenToEntity(e : Entity) -> void:
	if not e.is_connected("move", self, "_on_entity_move"):
		e.connect("move", self, "_on_entity_move", [e, e.hex.qrs])
	if not e.is_connected("position_changed", self, "_on_entity_position_changed"):
		e.connect("position_changed", self, "_on_entity_position_changed", [e, e.hex.qrs])

func _UnlistenToEntity(e : Entity) -> void:
	if e.is_connected("move", self, "_on_entity_move"):
		e.disconnect("move", self, "_on_entity_move")
	if e.is_connected("position_changed", self, "_on_entity_position_changed"):
		e.disconnect("position_changed", self, "_on_entity_position_changed")

func _RelistenEntity(e : Entity) -> void:
	_UnlistenToEntity(e)
	_ListenToEntity(e)

func _RemoveEntityFromCell(e : Entity, qrs : Vector3) -> void:
	var eidx = _cells[qrs].find(e.uuid)
	if eidx >= 0:
		_cells[qrs].remove(eidx)
		if _cells[qrs].size() <= 0:
			_cells.erase(qrs)

func _AddEntityToCell(e : Entity) -> void:
	if not e.hex.qrs in _cells:
		_cells[e.hex.qrs] = []
	if _cells[e.hex.qrs].find(e.uuid) < 0:
		_cells[e.hex.qrs].append(e.uuid)


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func add_entity(e : Entity) -> void:
	if e.uuid != "" and e.hex.is_valid():
		if not e.uuid in _entities:
			_entities[e.uuid] = e
			_AddEntityToCell(e)
			_ListenToEntity(e)

func remove_entity(e : Entity) -> void:
	if e.uuid != "":
		if e.hex.qrs in _cells:
			_RemoveEntityFromCell(e, e.hex.qrs)
		if e.uuid in _entities:
			_UnlistenToEntity(e)
			_entities.erase(e.uuid)

func has_entity(e : Entity) -> bool:
	return e.uuid in _entities

func get_entity_by_uuid(uuid : String) -> Entity:
	if uuid in _entities:
		return _entities[uuid]
	return null

func get_entities_within_range(point : Vector2, r : float) -> Dictionary:
	var pcell = HexCell.new(point, true)
	
	for cell in _cells.keys():
		if cell.distance_to(pcell) < r:
			pass
	
	return {}


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_entity_move(e : Entity, qrs : Vector3, dir : int, amount : int) -> void:
	if amount <= 0:
		return
	
	if dir >= 0 and dir < 6:
		var cell : HexCell = (HexCell.new(qrs)).get_neighbor(dir, amount)
		# TODO: Test to see if there is collision along this route!
		if cell != null:
			e.hex = cell

func _on_entity_position_changed(e : Entity, qrs : Vector3) -> void:
	if e.hex.qrs != qrs:
		_RemoveEntityFromCell(e, qrs)
		_AddEntityToCell(e)
		_RelistenEntity(e)


