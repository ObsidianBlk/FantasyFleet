extends Control


# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal group_selected(group_name)

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var placeholder_text : String = "[ No Group Selected ]"

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var grouplist_node : MenuButton = $GroupList

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	var popup : PopupMenu = grouplist_node.get_popup()
	popup.connect("index_pressed", self, "_on_index_pressed", [popup])
	grouplist_node.text = placeholder_text
	_UpdateGroupList()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _GroupReadable(group_name : String) -> String:
	return group_name.replace("_", " ").capitalize()

func _UpdateGroupList() -> void:
	if grouplist_node:
		var menu : PopupMenu = grouplist_node.get_popup()
		menu.clear()
		
		var glist : Array = EIM.get_group_list()
		for i in range(glist.size()):
			var group_name : String = glist[i]
			var group_readable_name : String = _GroupReadable(group_name)
			menu.add_item(group_readable_name, i)
			menu.set_item_metadata(i, {"name": group_name, "readable": group_readable_name})
		


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------
func _on_index_pressed(idx : int, menu : PopupMenu) -> void:
	var meta = menu.get_item_metadata(idx)
	if typeof(meta) == TYPE_DICTIONARY:
		grouplist_node.text = meta.readable
		emit_signal("group_selected", meta.name)

