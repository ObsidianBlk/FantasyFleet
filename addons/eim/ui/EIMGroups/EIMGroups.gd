tool
extends Control

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _tree_root : TreeItem = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var tree_node : Tree = $Groups/Tree

onready var gc_line_node : LineEdit = $Groups/GroupCreator/LineEdit
onready var gc_add_node : Button = $Groups/GroupCreator/AddGroup

onready var input_list_node : ItemList = $Inputs/ItemList

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	tree_node.columns = 2
	EIM.connect("eim_initialized", self, "_on_eim_initialized")
	EIM.connect("eim_deactivated", self, "_on_eim_deactivated")
	tree_node.connect("button_pressed", self, "_on_tree_button_pressed")
	gc_line_node.connect("text_changed", self, "_on_groupcreator_text_changed")
	gc_add_node.connect("pressed", self, "_on_group_creator_add_pressed")
	_BuildTree()
	_RefreshInputList()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _AddGroupToTree(group_name : String) -> TreeItem:
	if _tree_root == null:
		return null
	
	var tree_item_group : TreeItem = tree_node.create_item(_tree_root)
	tree_item_group.set_text(0, group_name)
	tree_item_group.add_button(
		1, preload("res://addons/eim/icons/big_x.svg"), 
		-1, false, 
		"Remove group \"%s\"."%[group_name]
	)
	tree_item_group.set_metadata(0, group_name)
	return tree_item_group


func _AddActionToGroup(tree_item_group : TreeItem, action_name : String) -> TreeItem:
	if tree_item_group == null:
		return null
	var group_name = tree_item_group.get_metadata(0)
	if typeof(group_name) != TYPE_STRING:
		return null
	if not group_name.is_valid_identifier():
		return null
	
	var tree_item_action : TreeItem = tree_node.create_item(tree_item_group)
	tree_item_action.set_text(0, action_name)
	tree_item_action.add_button(
		1, preload("res://addons/eim/icons/big_x.svg"), 
		-1, false, 
		"Remove action \"%s\" from group \"%s\"."%[action_name, group_name]
	)
	tree_item_action.set_metadata(0, {"group":group_name, "action":action_name})
	return tree_item_action
	


func _BuildTree() -> void:
	if _tree_root == null:
		_tree_root = tree_node.create_item()
		tree_node.set_hide_root(true)
	else:
		_ClearTree()
	
	var group_list : Array = EIM.get_group_list()
	for group_name in group_list:
		var tree_item_group : TreeItem = _AddGroupToTree(group_name)
		
		var action_list : Array = EIM.get_group_action_list(group_name)
		for action_name in action_list:
			var _tree_item_action : TreeItem = _AddActionToGroup(tree_item_group, action_name)


func _ClearTree() -> void:
	if _tree_root == null:
		return
	
	var item : TreeItem = _tree_root.get_children()
	if item != null:
		_tree_root.remove_child(item)
		item.free()
		_ClearTree()


func _RefreshInputList() -> void:
	input_list_node.clear()
	var pspl : Array = ProjectSettings.get_property_list()
	for prop in pspl:
		if prop.name.begins_with("input/"):
			if not EIM.is_action_assigned_group(prop.name):
				input_list_node.add_item(prop.name)

# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_eim_initialized(proj_name : String) -> void:
	_BuildTree()

func _on_eim_deactivated() -> void:
	_ClearTree()

func _on_tree_button_pressed(item : TreeItem, col : int, id : int) -> void:
	var meta = item.get_metadata(0)
	if typeof(meta) == TYPE_STRING:
		EIM.drop_group(meta)
		var parent : TreeItem = item.get_parent()
		if parent:
			parent.remove_child(item)
			item.free()
	else:
		print("Trying to remove action \"", meta.action, "\" from group \"", meta.group, "\".")

func _on_groupcreator_text_changed(text : String) -> void:
	gc_add_node.disabled = (text == null or not text.is_valid_identifier())


func _on_group_creator_add_pressed() -> void:
	if EIM.set_group(gc_line_node.text):
		_AddGroupToTree(gc_line_node.text)
		gc_line_node.text = ""
		gc_add_node.disabled = true


func _on_inputs_refresh_pressed():
	_RefreshInputList()
