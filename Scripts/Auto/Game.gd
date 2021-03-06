extends Node

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal input_bounced(event)
signal view_mode_changed(mode)
signal game_config_loading()
signal game_config_loaded(conf)
signal game_config_load_failed(err, config_path)
signal game_config_saving(conf)
signal game_config_saved()
signal game_config_save_failed(err, config_path)


# -------------------------------------------------------------------------
# Constants and ENUMs
# -------------------------------------------------------------------------
const DEFAULT_CONFIG_PATH : String = "user://FantasyFleet.cfg"

enum VIEW {MODE_2D=0, MODE_3D=1}

# -------------------------------------------------------------------------
# Export Variables
# -------------------------------------------------------------------------
export (VIEW) var view_mode : int = VIEW.MODE_2D		setget set_view_mode

# -------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------
var _game_config : ConfigFile = null
var _game_config_path : String = ""

var _profiles : Array = []
var _spid : int = -1 # selected profile id. -1 = no profile selected

# -------------------------------------------------------------------------
# Onready Variables
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Setters / Getters
# -------------------------------------------------------------------------
func set_view_mode(vm : int) -> void:
	if VIEW.values().find(vm) >= 0:
		view_mode = vm
		emit_signal("view_mode_changed", view_mode)

# -------------------------------------------------------------------------
# Override Methods
# -------------------------------------------------------------------------
func _ready() -> void:
	pass

# -------------------------------------------------------------------------
# Private Methods
# -------------------------------------------------------------------------
func _GetProfileID(profile_name : String) -> int:
	for pid in range(_profiles.size()):
		if _profiles[pid].name == profile_name:
			return pid
	return -1


# -------------------------------------------------------------------------
# Public Methods
# -------------------------------------------------------------------------
func bounce_input(event) -> void:
	emit_signal("input_bounced", event)

func has_profile(profile_name : String) -> bool:
	return _GetProfileID(profile_name) >= 0

func create_profile(profile_name : String) -> int:
	if _GetProfileID(profile_name) >= 0:
		return ERR_DUPLICATE_SYMBOL
	_profiles.append({
		"name":profile_name
	})
	return OK

func remove_profile(profile_name : String) -> int:
	var pid : int = _GetProfileID(profile_name)
	if pid >= 0:
		_profiles.remove(pid)
		return OK
	return ERR_DOES_NOT_EXIST

func select_profile(profile_name : String) -> int:
	var pid : int = _GetProfileID(profile_name)
	if pid >= 0:
		_spid = pid
		return OK
	return ERR_DOES_NOT_EXIST

func get_profile() -> Dictionary:
	if _spid >= 0 and _spid < _profiles.size():
		return _profiles[_spid]
	return {}

func get_profile_list() -> Array:
	var parr : Array = []
	for pid in range(_profiles.size()):
		parr.append(_profiles[pid].name)
	return parr

func config_load(config_path : String = DEFAULT_CONFIG_PATH) -> int:
	emit_signal("game_config_loading")
	var conf : ConfigFile = ConfigFile.new()
	var err : int = conf.load(config_path)
	if err != OK:
		emit_signal("game_config_load_failed", err, config_path)
	else:
		_game_config_path = config_path
		_game_config = conf
		emit_signal("game_config_loaded", _game_config)
	return err

func config_save() -> int:
	if _game_config == null:
		_game_config = ConfigFile.new()
		_game_config_path = DEFAULT_CONFIG_PATH
	emit_signal("game_config_saving", _game_config)
	var err : int = _game_config.save(_game_config_path)
	if err != OK:
		emit_signal("game_config_save_failed", err, _game_config_path)
	else:
		emit_signal("game_config_saved")
	return err

# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

