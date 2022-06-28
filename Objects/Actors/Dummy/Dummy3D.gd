extends Spatial


# -----------------------------------------------------------------------------
# Constants and ENUMs
# -----------------------------------------------------------------------------
const _ENTITY_SIGNALS = [
	["entity_freed", "_on_entity_freed"],
	["position_changed", "_on_position_changed"]
]


# -----------------------------------------------------------------------------
# Exports
# -----------------------------------------------------------------------------
export var entity : Resource = null


# -----------------------------------------------------------------------------
# Setters/Getters
# -----------------------------------------------------------------------------
func set_entity(e : Resource) -> void:
	if (e == null or e is Entity) and e != entity:
		_DisconnectEntity()
		entity = e
		_ReadyEntity()


# -----------------------------------------------------------------------------
# Override Methods
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------
func _DisconnectEntity() -> void:
	if entity != null:
		for info in _ENTITY_SIGNALS:
			entity.disconnect(info[0], self, info[1])


func _ReadyEntity() -> void:
	if entity != null:
		for info in _ENTITY_SIGNALS:
			entity.connect(info[0], self, info[1])


# -----------------------------------------------------------------------------
# Public Methods
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# Handler Methods
# -----------------------------------------------------------------------------
func _on_entity_freed() -> void:
	set_entity(null)


func _on_position_changed() -> void:
	pass


