extends Resource
class_name HexMapData


# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal entity_added(uuid)
signal entity_removed(uuid)

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _cells : Dictionary = {}
var _entities : Dictionary = {}
var _cell_size : float = 1.0
var _color_normal : Color = Color(0,1,0)
var _color_highlight : Color = Color(1,0,0)
var _color_focus : Color = Color(0,0,1)

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _get(property : String):
	match property:
		"entities":
			return _entities.values()
		"cell_size":
			return _cell_size
		"color_normal":
			return _color_normal
		"color_focus":
			return _color_focus
		"color_highlight":
			return _color_highlight
	
	return null


func _set(property : String, value) -> bool:
	var success : bool = true
	
	match property:
		"entities":
			if typeof(value) == TYPE_ARRAY:
				if _entities.empty():
					for e in value:
						if e is Entity:
							add_entity(e)
				else : success = false
			else : success = false
		"cell_size":
			if typeof(value) == TYPE_REAL:
				if value > 0.0:
					_cell_size = value
				else : success = false
			else : success = false
		"color_normal":
			if typeof(value) == TYPE_COLOR:
				_color_normal = value
			else : success = false
		"color_focus":
			if typeof(value) == TYPE_COLOR:
				_color_focus = value
			else : success = false
		"color_highlight":
			if typeof(value) == TYPE_COLOR:
				_color_highlight = value
			else : success = false
		_:
			success = false
	
	if success:
		property_list_changed_notify()
	return success


func _get_property_list() -> Array:
	# NOTE: Hinting for "entities" is based on information found...
	# https://stackoverflow.com/questions/71175503/how-to-add-array-with-hint-and-hint-string
	var props : Array = [
		{
			name = "entities",
			type = TYPE_ARRAY,
			hint = 24,
			hint_string = str(TYPE_OBJECT) + "/" + str(PROPERTY_HINT_RESOURCE_TYPE) + ":Entity",
			usage = PROPERTY_USAGE_STORAGE
		},
		{
			name = "cell_size",
			type = TYPE_REAL,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "color_normal",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "color_focus",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "color_highlight",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT
		}
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
func initialize() -> void:
	for e in _entities.values():
		emit_signal("entity_added", e)

func add_entity(e : Entity) -> void:
	if e.uuid != "" and e.hex.is_valid():
		if not e.uuid in _entities:
			_entities[e.uuid] = e
			_AddEntityToCell(e)
			_ListenToEntity(e)
			emit_signal("entity_added", e)

func remove_entity(e : Entity) -> void:
	if e.uuid != "":
		if e.hex.qrs in _cells:
			_RemoveEntityFromCell(e, e.hex.qrs)
		if e.uuid in _entities:
			_UnlistenToEntity(e)
			_entities.erase(e.uuid)
			emit_signal("entity_removed", e)

func has_entity(e : Entity) -> bool:
	return e.uuid in _entities

func get_entity_by_uuid(uuid : String) -> Entity:
	if uuid in _entities:
		return _entities[uuid]
	return null

func get_entities_in_cell(cell : HexCell) -> Array:
	if cell.qrs in _cells:
		return _cells[cell.qrs].duplicate()
	return []

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


