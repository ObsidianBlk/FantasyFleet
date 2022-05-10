extends Node2D


# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var map_data : Resource = null		setget set_map_data


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _mouse_cell : HexCell = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_map_data(data : Resource) -> void:
	if data == null or data is HexMapData:
		map_data = data


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	HexMap.connect("map_data_changed", self, "_on_map_data_changed")
	HexMap.connect("input_bounced", self, "_on_input_bounced")

func _process(_delta : float) -> void:
	update()

func _draw() -> void:
	if map_data == null:
		return
	
	var origin : HexCell = HexCell.new()
	var cells : Array = origin.get_region(5)
	for cell in cells:
		if not cell.eq(_mouse_cell):
			_DrawHex(cell, map_data.cell_size, map_data.color_normal)
	if _mouse_cell != null:
		print("Drawing Mouse Cell: ", _mouse_cell.qrs)
		_DrawHex(_mouse_cell, map_data.cell_size, map_data.color_highlight)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _DrawHex(cell : HexCell, size : float, color : Color) -> void:
	var pos : Vector2 = cell.to_point()
	var points : Array = []
	var point : Vector2 = Vector2(0, -size) if cell.orientation == 0 else Vector2(-size, 0)
	var offset : Vector2 = pos * size
	points.append(point + offset)
	for i in range(1, 6):
		var rad = deg2rad(60 * i)
		points.append(point.rotated(rad) + offset)
	points.append(point + offset)
	draw_polyline(PoolVector2Array(points), color, 1, true)


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_map_data_changed(hmd : HexMapData) -> void:
	set_map_data(hmd)


func _on_input_bounced(event) -> void:
	if event is InputEventMouseMotion and map_data != null:
		if _mouse_cell == null:
			_mouse_cell = HexCell.new()
		_mouse_cell.from_point(event.position / map_data.cell_size)
