extends Resource
class_name HexMapData

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _cells : Dictionary = {}


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
func _RemoveEntityFromCell(e : Entity, cell : Vector3) -> void:
	var eidx = _cells[cell].find(e)
	if eidx >= 0:
		_cells[cell].remove(eidx)
		if _cells[cell].size() <= 0:
			_cells.erase(cell)
		e.disconnect("move", self, "_on_entity_move")
		e.disconnect("position_changed", self, "_on_entity_position_changed")


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func add_entity(e : Entity) -> void:
	var vhpos : VectorHex = VectorHex.new(e.position)
	if vhpos.is_valid():
		if not vhpos.qrs in _cells:
			_cells[vhpos.qrs] = []
		if _cells[vhpos.qrs].find(e) < 0:
			_cells[vhpos.qrs].append(e)
			e.connect("move", self, "_on_entity_move", [e, vhpos.qrs])
			e.connect("position_changed", self, "_on_entity_position_changed", [e, vhpos.qrs])


func get_entities_within_range(point : Vector2, r : float) -> Dictionary:
	var pcell = VectorHex.new(point, true)
	
	for cell in _cells.keys():
		if cell.distance_to(pcell) < r:
			pass
	
	return {}


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_entity_move(e : Entity, cell : Vector3, dir : int, amount : int) -> void:
	if amount <= 0:
		return
	
	if dir >= 0 and dir < 6:
		var vh : VectorHex = (VectorHex.new(cell)).get_neighbor(dir, amount)
		# TODO: Test to see if there is collision along this route!
		if vh != null:
			e.position = vh

func _on_entity_position_changed(e : Entity, cell : Vector3) -> void:
	if e.position != cell:
		_RemoveEntityFromCell(e, cell)
		add_entity(e)


