extends MarginContainer

signal join_requested(address, port)
signal host_requested(port, max_players)
signal disconnect_network_requested()


# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export var visible_at_start : bool = false

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------
onready var btn_host_node : Button = $VBC/NetworkMode/Host
onready var btn_join_node : Button = $VBC/NetworkMode/Join
onready var btn_disconnect_node : Button = $VBC/NetworkMode/Disconnect

onready var join_address_node : LineEdit = $VBC/JoinMode/Address/LineEdit
onready var join_port_node : LineEdit = $VBC/JoinMode/Port/LineEdit

onready var host_port_node : LineEdit = $VBC/HostMode/Port/LineEdit
onready var host_players_node : LineEdit = $VBC/HostMode/MaxPlayers/LineEdit

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	$VBC/HostMode.visible = false
	$VBC/JoinMode.visible = false
	visible = visible_at_start
	if visible:
		_UpdateNetworkModeButtons()

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _UpdateNetworkModeButtons() -> void:
	if get_tree().has_network_peer():
		btn_host_node.visible = false
		btn_join_node.visible = false
		btn_disconnect_node.visible = true
	else:
		btn_host_node.visible = true
		btn_join_node.visible = true
		btn_disconnect_node.visible = false

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

func _on_ui_requested(ui_name : String) -> void:
	visible = (self.name == ui_name)
	if visible:
		_UpdateNetworkModeButtons()
		grab_focus()

func _on_ui_toggle_requested(ui_name : String) -> void:
	if self.name == ui_name:
		visible = not visible
		if visible:
			_UpdateNetworkModeButtons()
			grab_focus()

func _on_Host_pressed():
	$VBC/NetworkMode.visible = false
	$VBC/HostMode.visible = true


func _on_Join_pressed():
	$VBC/NetworkMode.visible = false
	$VBC/JoinMode.visible = true

func _on_Disconnect_pressed():
	visible = false
	emit_signal("disconnect_network_requested")

func _on_Connect_pressed():
	if join_address_node.text == "":
		return
	if not join_port_node.text.is_valid_integer():
		return
	$VBC/NetworkMode.visible = true
	$VBC/JoinMode.visible = false
	visible = false
	emit_signal("join_requested", join_address_node.text, join_port_node.text.to_int())



func _on_Hosting_pressed():
	if not host_port_node.text.is_valid_integer():
		return
	if not host_players_node.text.is_valid_integer():
		return
	$VBC/NetworkMode.visible = true
	$VBC/HostMode.visible = false
	visible = false
	emit_signal("host_requested", host_port_node.text.to_int(), host_players_node.text.to_int())


func _on_JoinCancel_pressed():
	$VBC/JoinMode.visible = false
	$VBC/NetworkMode.visible = true


func _on_HostCancel_pressed():
	$VBC/HostMode.visible = false
	$VBC/NetworkMode.visible = true
