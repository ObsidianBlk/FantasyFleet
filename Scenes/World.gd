extends Node2D

onready var _view3d_node : Viewport = $Viewport3D
onready var _view2d_node : Viewport = $Viewport2D

func _ready() -> void:
	_on_GameScreen_resized()
	call_deferred("_KickPig")


func _KickPig() -> void:
	var hmd : HexMapData = HexMapData.new()
	hmd.cell_size = 10.0
	HexMap.hex_map_data = hmd

func _on_GameScreen_resized():
	if _view2d_node:
		_view2d_node.size = OS.window_size
	if _view3d_node:
		_view3d_node.size = OS.window_size
