tool
extends EditorPlugin

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var interface = preload("res://addons/eim/Interface.tscn").instance()

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------

func _enter_tree():
	get_editor_interface().get_editor_viewport().add_child(interface)
	make_visible(false)


func _exit_tree():
	if interface:
		interface.queue_free()

func has_main_screen() -> bool:
	return true

func get_plugin_name() -> String:
	return "Extended Input Manager"

func get_plugin_icon() -> Texture:
	return preload("res://addons/eim/icons/controller_imap.svg")

func make_visible(visible : bool) -> void:
	if interface:
		interface.visible = visible
