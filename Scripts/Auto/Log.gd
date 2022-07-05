extends Node

# -----------------------------------------------------------------------------
# Signals
# -----------------------------------------------------------------------------
signal entry_logged(entry)
signal log_changed()

# -----------------------------------------------------------------------------
# Constants and ENUMs
# -----------------------------------------------------------------------------
enum PRIORITY {Info=0, Debug=1, Warning=2, Error=3}

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
var _entries : Array = []
var _max_entries : int = 5000

# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Public Methods
# -----------------------------------------------------------------------------
func set_max_entries(me : int) -> void:
	if me > 0:
		_max_entries = me
		if _entries.size() >= _max_entries:
			var start : int = _entries.size() - _max_entries
			var end : int = _entries.size() - 1
			_entries = _entries.slice(start, end)
			emit_signal("log_changed")

func get_max_entries() -> int:
	return _max_entries

func get_entry_count() -> int:
	return _entries.size()

func get_entry(idx : int) -> Dictionary:
	var re : Dictionary = {}
	if idx >= 0 and idx < _entries.size():
		var entry : Dictionary = _entries[idx]
		for key in entry.keys():
			re[key] = entry[key]
	return re

func get_entries(start : int, count : int) -> Array:
	var ent : Array = []
	var size : int = _entries.size()
	if start >= 0 and start < size:
		for i in range(count):
			if start + i >= size:
				break
			ent.append(get_entry(start + i))
	return ent

func entry(priority : int, message : String, metadata = null) -> void:
	if PRIORITY.values().find(priority) < 0:
		return
	
	var e : Dictionary = {
		"timestamp": OS.get_unix_time(),
		"priority": priority,
		"message": message,
		"meta": metadata
	}
	_entries.append(e)
	if _entries.size() >= _max_entries:
		_entries.pop_front()
	emit_signal("entry_logged", e)
	emit_signal("log_changed")

func remove(idx : int) -> void:
	if idx >= 0 and idx < _entries.size():
		_entries.remove(idx)
		emit_signal("log_changed")

func clear() -> void:
	_entries.clear()
	emit_signal("log_changed")


