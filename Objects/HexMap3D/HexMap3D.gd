extends Spatial


# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var map_data : Resource = null		setget set_map_data
export var active_camera_group : String = ""

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _grid_material_normal : SpatialMaterial = null
var _grid_material_focus : SpatialMaterial = null
var _grid_material_highlight : SpatialMaterial = null

var _last_mouse_pos : Vector2 = Vector2.ZERO
var _mouse_cell : HexCell = null
var _grid_mesh_dirty : bool = true

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var _meshinst_node : MeshInstance = $MeshInstance

# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_map_data(data : Resource) -> void:
	if data == null or data is HexMapData:
		map_data = data
		if _grid_material_normal:
			_grid_material_normal.albedo_color = map_data.color_normal
		if _grid_material_highlight:
			_grid_material_highlight.albedo_color = map_data.color_highlight
		if _grid_material_focus:
			_grid_material_focus.albedo_color = map_data.color_focus


# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	_grid_material_normal = SpatialMaterial.new()
	_grid_material_normal.flags_unshaded = true
	_grid_material_normal.albedo_color = Color(0,1,0) if map_data == null else map_data.color_normal
	
	_grid_material_highlight = _grid_material_normal.duplicate()
	_grid_material_highlight.albedo_color = Color(1,0,0) if map_data == null else map_data.color_highlight
	
	_grid_material_focus = _grid_material_normal.duplicate()
	_grid_material_focus.albedo_color = Color(0,0,1) if map_data == null else map_data.color_focus
	
	Game.connect("input_bounced", self, "_on_input_bounced")
	HexMap.connect("map_data_changed", self, "_on_map_data_changed")

func _process(_delta : float) -> void:
	if map_data != null:
		if _meshinst_node.mesh == null or _grid_mesh_dirty:
			_grid_mesh_dirty = false
			_BuildMesh()

func _physics_process(_delta) -> void:
	if active_camera_group != "" and map_data != null:
		var cams = get_tree().get_nodes_in_group(active_camera_group)
		if cams.size() > 0:
			var p : Plane = Plane(Vector3.UP, 0.0)
			var from : Vector3 = cams[0].project_ray_origin(_last_mouse_pos)
			var dir : Vector3 = cams[0].project_ray_normal(_last_mouse_pos)
			#print("Last Mouse Pos: ", _last_mouse_pos, " | From: ", from, " | Dir: ", dir)
			var intersect = p.intersects_ray(from, dir)
			if intersect != null:
				#print("Raycast Intersect: ", intersect)
				if _mouse_cell == null:
					_mouse_cell = HexCell.new()
				_mouse_cell.from_point(Vector2(intersect.x, intersect.z) / map_data.cell_size)
				#print("From Pos: ", Vector2(intersect.x, intersect.z), " -> Mouse Cell: ", _mouse_cell.qrs)
				_grid_mesh_dirty = true

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _BuildMesh() -> void:
	var st : SurfaceTool = SurfaceTool.new()
	var origin : HexCell = HexCell.new()
	var region : Array = origin.get_region(5)
	var size : float = map_data.cell_size
	if _meshinst_node.mesh != null:
		_meshinst_node.mesh.clear_surfaces()
	for cell in region:
		if not cell.eq(_mouse_cell):
			_BuildHex(st, cell, size, _grid_material_normal)
	if Game.view_mode == Game.VIEW.MODE_3D and _mouse_cell != null:
		_BuildHex(st, _mouse_cell, size, _grid_material_highlight)


func _BuildHex(st : SurfaceTool, cell : HexCell, size : float, mat : Material) -> void:
	var pos : Vector2 = cell.to_point()
	
	st.begin(Mesh.PRIMITIVE_LINE_LOOP)
	var point : Vector2 = Vector2(0, -size) if cell.orientation == 0 else Vector2(-size, 0)
	var offset : Vector2 = pos * size
	
	#st.add_color(map_data.color_normal)
	st.add_vertex(Vector3(point.x + offset.x, 0, point.y + offset.y))
	for i in range(1, 6):
		var rad = deg2rad(60 * i)
		var p = point.rotated(rad) + offset
		#st.add_color(map_data.color_normal)
		st.add_vertex(Vector3(p.x, 0, p.y))
	
	st.set_material(mat)
	if _meshinst_node.mesh == null:
		_meshinst_node.mesh = st.commit()
	else:
		_meshinst_node.mesh = st.commit(_meshinst_node.mesh)

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_map_data_changed(hmd : HexMapData) -> void:
	set_map_data(hmd)

func _on_input_bounced(event) -> void:
	if event is InputEventMouseMotion:
		_last_mouse_pos = event.position


