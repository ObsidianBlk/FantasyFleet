extends Camera2D

# -----------------------------------------------------------------------------
# Export Variables
# -----------------------------------------------------------------------------
export var group_name : String = ""						setget set_group_name
export var partner_camera3d_path : NodePath = ""


# -----------------------------------------------------------------------------
# Setters / Getters
# -----------------------------------------------------------------------------
func set_group_name(gn : String) -> void:
	if group_name != "" and is_in_group(group_name):
		remove_from_group(group_name)
	group_name = gn
	if current and group_name != "" and not is_in_group(group_name):
		add_to_group(group_name)


#func set_current(c : bool) -> void:
#	.set_current(c)
#	if current and group_name != "":
#		print("Added to group: ", group_name)
#		add_to_group(group_name)
#	elif not current and group_name != "" and is_in_group(group_name):
#		remove_from_group(group_name)


# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------

func _set(property : String, value) -> bool:
	if property == "current" and typeof(value) == TYPE_BOOL:
		current = value
		if value == true and group_name != "":
			add_to_group(group_name)
		elif value == false and group_name != "" and is_in_group(group_name):
			remove_from_group(group_name)
		return true
	return false


func _process(_delta : float) -> void:
	if partner_camera3d_path == "":
		return
	
	var c3d = get_node_or_null(partner_camera3d_path)
	if c3d is Spatial and c3d.has_method("set_current") and c3d.current == true:
		position = Vector2(c3d.global_transform.origin.x, c3d.global_transform.origin.z)


# -----------------------------------------------------------------------------
# Public Methods
# -----------------------------------------------------------------------------

