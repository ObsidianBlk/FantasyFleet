extends Spatial

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
onready var _meshinst_node : MeshInstance = $MeshInstance

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
		if _meshinst_node.mesh == null:
			_BuildMesh()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _BuildMesh() -> void:
	var st : SurfaceTool = SurfaceTool.new()
	var origin : HexCell = HexCell.new()
	var region : Array = origin.get_region(5)
	for cell in region:
		_BuildHex(st, cell.to_point(), 10, cell.orientation)

func _BuildHex(st : SurfaceTool, pos : Vector2, size : float, orientation : int) -> void:
	st.begin(Mesh.PRIMITIVE_LINE_LOOP)
	var point : Vector2 = Vector2(0, -size) if orientation == 0 else Vector2(-size, 0)
	var offset : Vector2 = pos * size
	
	print("Adding Vertex: ", point + offset)
	st.add_color(Color(0, 1, 0))
	st.add_vertex(Vector3(point.x + offset.x, 0, point.y + offset.y))
	for i in range(1, 6):
		var rad = deg2rad(60 * i)
		var p = point.rotated(rad) + offset
		print("Adding Vertex: ", p)
		st.add_color(Color(0, 1, 0))
		st.add_vertex(Vector3(p.x, 0, p.y))
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

