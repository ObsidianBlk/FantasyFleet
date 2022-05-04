extends Node2D

onready var _view3d_node : Viewport = $Viewport3D
onready var _view2d_node : Viewport = $Viewport2D

func _ready() -> void:
	_on_GameScreen_resized()


func _on_GameScreen_resized():
	if _view2d_node:
		_view2d_node.size = OS.window_size
	if _view3d_node:
		_view3d_node.size = OS.window_size
