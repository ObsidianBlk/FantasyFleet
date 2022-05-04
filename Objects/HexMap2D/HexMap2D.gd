extends Node2D


# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var map_data : Resource = null		setget set_map_data


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------


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

func _process(_delta : float) -> void:
	if map_data != null:
		update()

func _draw() -> void:
	var origin : HexCell = HexCell.new()
	var cells : Array = origin.get_region(5)
	for cell in cells:
		var pos = cell.to_point()
		_DrawHex(pos, 20, cell.orientation)

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _DrawHex(pos : Vector2, size : float, orientation : int) -> void:
	var points : Array = []
	var point : Vector2 = Vector2(0, -size) if orientation == 0 else Vector2(-size, 0)
	var offset : Vector2 = pos * size
	points.append(point + offset)
	for i in range(1, 6):
		var rad = deg2rad(60 * i)
		points.append(point.rotated(rad) + offset)
	points.append(point + offset)
	draw_polyline(PoolVector2Array(points), Color(0,1,0), 1, true)


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

