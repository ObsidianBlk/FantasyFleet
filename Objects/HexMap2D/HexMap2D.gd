extends Node2D


# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var map_data : Resource = null		setget set_map_data
export var active_camera_group : String = ""


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
	Game.connect("input_bounced", self, "_on_input_bounced")
	HexMap.connect("map_data_changed", self, "_on_map_data_changed")

func _process(_delta : float) -> void:
	update()

func _draw() -> void:
	if map_data == null:
		return
	
	var rids : Array = HexMap.get_region_ids()
	for rid in rids:
		var region : Array = HexMap.get_region(rid)
		for cell in region:
			if not cell.eq(_mouse_cell):
				_DrawHex(cell, map_data.cell_size, map_data.color_normal)
	
	if Game.view_mode == Game.VIEW.MODE_2D and _mouse_cell != null:
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
		var cams = get_tree().get_nodes_in_group(active_camera_group)
		if cams.size() <= 0:
			return
		
		if not cams[0] is Camera2D:
			print("No active camera")
			return
		var cam = cams[0]
		
		var view = get_parent()
		if not view is Viewport:
			print("Not child of viewport")
			return
		
		if _mouse_cell == null:
			_mouse_cell = HexCell.new()
		var pos : Vector2 = (event.position + cam.global_position) - (view.size * 0.5)
		_mouse_cell.from_point(pos / map_data.cell_size)

