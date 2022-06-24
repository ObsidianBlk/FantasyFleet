tool
extends Control

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal group_selected(group_name)

# -------------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------------
const COLUMN_DESCRIPTION_COLOR : Color = Color(0.4, 0.4, 0.4)
const COLOR_ICON_ACTION_WARNING : Color = Color.crimson#Color(0.647059, 0.333333, 0.490196)
const COLOR_ICON_ACTION_DEFAULT : Color = Color.white

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _tree_root : TreeItem = null

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var tree_node : Tree = $Groups/Tree

onready var gc_line_node : LineEdit = $Groups/GroupCreator/LineEdit
onready var gc_uniquecheck_node : CheckBox = $Groups/GroupCreator/UniqueCheck
onready var gc_add_node : Button = $Groups/GroupCreator/AddGroup

onready var action_list_node : ItemList = $Inputs/ItemList

onready var action_filter_node : LineEdit = $Inputs/Refresh/ActionFilter/LineEdit
onready var action_filter_beginswith : CheckBox = $Inputs/Refresh/ActionFilter/Begins
onready var action_filter_caseless : CheckBox = $Inputs/Refresh/ActionFilter/Caseless

# ------------------------------------------------------------------S-------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	tree_node.columns = 8
	
	tree_node.set_column_expand(0, true)
	tree_node.set_column_min_width(0, 48)
	#tree_node.set_column_expand(1, false)
	tree_node.set_column_min_width(1, 64)
	tree_node.set_column_expand(2, false)
	tree_node.set_column_min_width(2, 18)
	tree_node.set_column_expand(3, false)
	tree_node.set_column_min_width(3, 18)
	tree_node.set_column_expand(4, false)
	tree_node.set_column_min_width(4, 18)
	tree_node.set_column_expand(5, false)
	tree_node.set_column_min_width(5, 18)
	#tree_node.set_column_expand(6, false)
	tree_node.set_column_min_width(6, 16)
	tree_node.set_column_expand(7, false)
	tree_node.set_column_min_width(7, 18)
	
	EIM.connect("initialized", self, "_on_eim_initialized")
	EIM.connect("deconstructed", self, "_on_eim_deconstructed")
	connect("visibility_changed", self, "_on_visibility_changed")
	connect("focus_entered", self, "_on_entered")
	connect("mouse_entered", self, "_on_entered")
	tree_node.connect("button_pressed", self, "_on_tree_button_pressed")
	tree_node.connect("item_edited", self, "_on_item_edited")
	tree_node.connect("item_selected", self, "_on_item_selected")
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
	
	tree_item_group.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	tree_item_group.set_text(1, "Unique Inputs")
	tree_item_group.set_editable(1, true)
	tree_item_group.set_selectable(2, false)
	tree_item_group.set_selectable(3, false)
	tree_item_group.set_selectable(4, false)
	tree_item_group.set_selectable(5, false)
	tree_item_group.set_selectable(6, false)
	if EIM.are_group_inputs_unique(group_name):
		tree_item_group.set_checked(1, true)
	
	tree_item_group.add_button(
		7, preload("res://addons/eim/icons/big_x.svg"), 
		-1, false, 
		"Remove group \"%s\"."%[group_name]
	)
	tree_item_group.set_metadata(0, group_name)
	return tree_item_group


func _AddActionToGroup(tree_item_group : TreeItem, action_data : Dictionary) -> TreeItem:
	if tree_item_group == null:
		return null
	var group_name = tree_item_group.get_metadata(0)
	if typeof(group_name) != TYPE_STRING:
		return null
	if not group_name.is_valid_identifier():
		return null
	
	var tree_item_action : TreeItem = tree_node.create_item(tree_item_group)
	tree_item_action.set_text(0, action_data.name)
	tree_item_action.set_text(1, action_data.desc)
	tree_item_action.set_custom_bg_color(1, COLUMN_DESCRIPTION_COLOR, true)
	tree_item_action.set_editable(1, true)
	tree_item_action.set_selectable(0, false)
	tree_item_action.set_selectable(2, false)
	tree_item_action.set_selectable(3, false)
	tree_item_action.set_selectable(4, false)
	tree_item_action.set_selectable(5, false)
	tree_item_action.set_selectable(6, false)
	
	if EIM.action_has_key_inputs(action_data.name):
		tree_item_action.set_icon(2, preload("res://addons/eim/icons/input_keyboard.svg"))
		if EIM.action_key_input_count(action_data.name) > 1:
			tree_item_action.set_icon_modulate(2, COLOR_ICON_ACTION_WARNING)
	if EIM.action_has_mouse_inputs(action_data.name):
		tree_item_action.set_icon(3, preload("res://addons/eim/icons/input_mouse.svg"))
		if EIM.action_mouse_input_count(action_data.name) > 1:
			tree_item_action.set_icon_modulate(3, COLOR_ICON_ACTION_WARNING)
	if EIM.action_has_joypad_button_inputs(action_data.name):
		tree_item_action.set_icon(4, preload("res://addons/eim/icons/input_joypad_buttons.svg"))
		if EIM.action_joypad_button_input_count(action_data.name) > 1:
			tree_item_action.set_icon_modulate(4, COLOR_ICON_ACTION_WARNING)
	if EIM.action_has_joypad_axii_inputs(action_data.name):
		tree_item_action.set_icon(5, preload("res://addons/eim/icons/input_joypad_axii.svg"))
		if EIM.action_joypad_axii_input_count(action_data.name) > 1:
			tree_item_action.set_icon_modulate(5, COLOR_ICON_ACTION_WARNING)
	
	tree_item_action.add_button(
		7, preload("res://addons/eim/icons/big_x.svg"), 
		-1, false, 
		"Remove action \"%s\" from group \"%s\"."%[action_data.name, group_name]
	)
	tree_item_action.set_metadata(0, {"group":group_name, "action":action_data.name})
	return tree_item_action


func _BuildTree() -> void:
	if not tree_node:
		return
		
	if _tree_root == null:
		_tree_root = tree_node.create_item()
		tree_node.set_hide_root(true)
	else:
		_ClearTree()
	
	var group_list : Array = EIM.get_group_list()
	for group_name in group_list:
		var tree_item_group : TreeItem = _AddGroupToTree(group_name)
		
		var action_list : Array = EIM.get_group_action_list(group_name)
		for action_data in action_list:
			var _tree_item_action : TreeItem = _AddActionToGroup(tree_item_group, action_data)


func _ClearTree() -> void:
	if _tree_root == null:
		return
	
	var item : TreeItem = _tree_root.get_children()
	if item != null:
		_tree_root.remove_child(item)
		item.free()
		_ClearTree()


func _RefreshTreeGroupAction(action_item : TreeItem) -> bool:
	var action_data = action_item.get_metadata(0)
	if EIM.has_action(action_data.action):
		if EIM.is_action_in_group(action_data.group, action_data.action):
			if EIM.action_has_key_inputs(action_data.action):
				action_item.set_icon(2, preload("res://addons/eim/icons/input_keyboard.svg"))
				if EIM.action_key_input_count(action_data.action) > 1:
					action_item.set_icon_modulate(2, COLOR_ICON_ACTION_WARNING)
				else:
					action_item.set_icon_modulate(2, COLOR_ICON_ACTION_DEFAULT)
			else:
				action_item.set_icon(2, null)
				action_item.set_icon_modulate(2, COLOR_ICON_ACTION_DEFAULT)
			
			if EIM.action_has_mouse_inputs(action_data.action):
				action_item.set_icon(3, preload("res://addons/eim/icons/input_mouse.svg"))
				if EIM.action_mouse_input_count(action_data.action) > 1:
					action_item.set_icon_modulate(3, COLOR_ICON_ACTION_WARNING)
				else:
					action_item.set_icon_modulate(3, COLOR_ICON_ACTION_DEFAULT)
			else:
				action_item.set_icon(3, null)
				action_item.set_icon_modulate(3, COLOR_ICON_ACTION_DEFAULT)
			
			if EIM.action_has_joypad_button_inputs(action_data.action):
				action_item.set_icon(4, preload("res://addons/eim/icons/input_joypad_buttons.svg"))
				if EIM.action_joypad_button_input_count(action_data.action) > 1:
					action_item.set_icon_modulate(4, COLOR_ICON_ACTION_WARNING)
				else:
					action_item.set_icon_modulate(4, COLOR_ICON_ACTION_DEFAULT)
			else:
				action_item.set_icon(4, null)
				action_item.set_icon_modulate(4, COLOR_ICON_ACTION_DEFAULT)
			
			if EIM.action_has_joypad_axii_inputs(action_data.action):
				action_item.set_icon(5, preload("res://addons/eim/icons/input_joypad_axii.svg"))
				if EIM.action_joypad_axii_input_count(action_data.action) > 1:
					action_item.set_icon_modulate(5, COLOR_ICON_ACTION_WARNING)
				else:
					action_item.set_icon_modulate(5, COLOR_ICON_ACTION_DEFAULT)
			else:
				action_item.set_icon(5, null)
				action_item.set_icon_modulate(5, COLOR_ICON_ACTION_DEFAULT)
			return true
	return false

func _RefreshTree() -> void:
	if _tree_root == null:
		return
	
	var group_item : TreeItem = _tree_root.get_children()
	while group_item != null:
		if typeof(group_item.get_metadata(0)) == TYPE_STRING:
			var action_item : TreeItem = group_item.get_children()
			var clear_list : Array = []
			while action_item != null:
				if not _RefreshTreeGroupAction(action_item):
					clear_list.append(action_item)
				action_item = action_item.get_next()
			for item in clear_list:
				group_item.remove_child(item)
				item.free()
			group_item = group_item.get_next()


func _ActionFilterPassed(action_name : String) -> bool:
	if action_filter_node.text != "":
		if action_filter_beginswith.pressed:
			if action_filter_caseless.pressed:
				return action_name.to_lower().begins_with(action_filter_node.text.to_lower())
			return action_name.begins_with(action_filter_node.text)
		else:
			if action_filter_caseless.pressed:
				return action_name.countn(action_filter_node.text) > 0
			return action_name.count(action_filter_node.text) > 0
	return true

func _RefreshInputList() -> void:
	if not action_list_node:
		return
	
	action_list_node.clear()
	var pspl : Array = ProjectSettings.get_property_list()
	for prop in pspl:
		if prop.name.begins_with("input/"):
			var action_name : String = prop.name.substr("input/".length())
			if not _ActionFilterPassed(action_name):
				continue
			if not EIM.is_action_assigned_group(action_name):
				action_list_node.add_item(action_name)


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_eim_initialized(proj_name : String) -> void:
	print("EIMGroups - Initialized")
	call_deferred("_BuildTree")

func _on_eim_deconstructed() -> void:
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
		EIM.drop_action_from_group(meta.group, meta.action)
		_BuildTree()
		_RefreshInputList()
		#print("Trying to remove action \"", meta.action, "\" from group \"", meta.group, "\".")

func _on_item_edited() -> void:
	var item : TreeItem = tree_node.get_selected()
	var col : int = tree_node.get_selected_column()
	if item and col == 1:
		var meta = item.get_metadata(0)
		if typeof(meta) == TYPE_DICTIONARY:
			EIM.set_group_action_description(meta.group, meta.action, item.get_text(col))
		if typeof(meta) == TYPE_STRING:
			EIM.set_group_inputs_unique(meta, item.is_checked(col))


func _on_item_selected() -> void:
	var sel : TreeItem = tree_node.get_selected()
	if sel:
		var meta = sel.get_metadata(0)
		if typeof(meta) == TYPE_STRING:
			emit_signal("group_selected", meta)

func _on_groupcreator_text_changed(text : String) -> void:
	gc_add_node.disabled = (text == null or not text.is_valid_identifier())


func _on_group_creator_add_pressed() -> void:
	if EIM.set_group(gc_line_node.text, gc_uniquecheck_node.pressed):
		_AddGroupToTree(gc_line_node.text)
		gc_line_node.text = ""
		gc_add_node.disabled = true


func _on_inputs_refresh_pressed():
	_RefreshInputList()


func _on_action_item_activated(idx : int):
	var item : TreeItem = tree_node.get_selected()
	if not item:
		return
	if typeof(item.get_metadata(0)) != TYPE_STRING:
		item = item.get_parent()
		if not item:
			return
		if typeof(item.get_metadata(0)) != TYPE_STRING:
			return
	
	# If we get here, item will be valid!
	
	var group_name : String = item.get_metadata(0)
	var action_name : String = action_list_node.get_item_text(idx)
	if EIM.add_action_to_group(group_name, action_name):
		_AddActionToGroup(item, {"name":action_name, "desc":EIM.get_group_action_description(group_name, action_name)})
		#_BuildTree()
		_RefreshInputList()
		

func _on_ActionFilter_text_changed(new_text : String) -> void:
	_RefreshInputList()

func _on_entered() -> void:
	_RefreshTree()
	_RefreshInputList()

func _on_visibility_changed():
	if visible:
		_on_entered()

func _on_ActionFilter_Begins_toggled(button_pressed : bool) -> void:
	_RefreshInputList()

func _on_ActionFilter_Caseless_toggled(button_pressed : bool) -> void:
	_RefreshInputList()
