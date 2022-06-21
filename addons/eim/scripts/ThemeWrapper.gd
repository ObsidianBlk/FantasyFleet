extends Object
tool

# -----------------------------------------------------------------------------
# Constants and ENUMs
# -----------------------------------------------------------------------------
enum TYPE {Colors=0, Constants=1, Fonts=2, Icons=3, Styles=4}

# -----------------------------------------------------------------------------
# Exports
# -----------------------------------------------------------------------------
export var theme_type : String = ""

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
var _customs : Dictionary = {}
var _controls : Array = []

# -----------------------------------------------------------------------------
# Private Methods
# -----------------------------------------------------------------------------

func _GetControlProperty(prop_name : String): # Dictionary or null
	for ref in _controls:
		var c = ref.get_ref()
		if not c:
			continue
		
		var props : Array = c.get_property_list()
		for prop in props:
			var idx : int = prop.name.find("/")
			if idx < 0:
				continue
			
			var prefix = prop.name.substr(0, idx)
			var pname = prop.name.substr(idx + 1)
			if pname == prop_name:
				var info : Dictionary = {"prop":prop, "ref":ref, "type":-1}
				match prefix:
					"custom_colors":
						info.type = TYPE.Colors
					"custom_constants":
						info.type = TYPE.Constants
					"custom_fonts":
						info.type = TYPE.Fonts
					"custom_icons":
						info.type = TYPE.Icons
					"custom_styles":
						info.type = TYPE.Styles
				return info
	return null

func _ControlHasProperty(c : Control, type : int, property : String) -> bool:
	match type:
		TYPE.Colors:
			property = "custom_colors/%s"%[property]
		TYPE.Constants:
			property = "custom_constants/%s"%[property]
		TYPE.Fonts:
			property = "custom_fonts/%s"%[property]
		TYPE.Icons:
			property = "custom_icons/%s"%[property]
		TYPE.Styles:
			property = "custom_styles/%s"%[property]
		_:
			return false
	
	var props : Array = c.get_property_list()
	for prop in props:
		if prop.name == property:
			return true
	return false

func _BuildControlProperties(state : Dictionary) -> void:
	for ref in _controls:
		var c = ref.get_ref()
		if not c:
			continue
		
		var props : Array = c.get_property_list()
		for prop in props:
			var idx : int = prop.name.find("/")
			if idx < 0:
				continue
			
			var prefix = prop.name.substr(0, idx)
			var pname = prop.name.substr(idx + 1)
			match prefix:
				"custom_colors":
					var override : bool = c.has_color_override(pname)
					state.colors.append({
						name=pname,
						type=TYPE_COLOR,
						usage=51 if override else 18
					})
				"custom_constants":
					var override : bool = c.has_constant_override(pname)
					state.consts.append({
						name=pname,
						type=prop.type,
						hint=prop.hint,
						hint_string=prop.hint_string,
						usage=51 if override else 18
					})
				"custom_fonts":
					var override : bool = c.has_font_override(pname)
					state.fonts.append({
						name=pname,
						type=TYPE_OBJECT,
						hint=PROPERTY_HINT_RESOURCE_TYPE,
						hint_string="Font",
						usage=51 if override else 18
					})
				"custom_icons":
					var override : bool = c.has_icon_override(pname)
					state.icons.append({
						name=pname,
						type=TYPE_OBJECT,
						hint=PROPERTY_HINT_RESOURCE_TYPE,
						hint_string="Texture",
						usage=51 if override else 18
					})
				"custom_styles":
					var override : bool = c.has_stylebox_override(pname)
					state.styles.append({
						name=pname,
						type=TYPE_OBJECT,
						hint=PROPERTY_HINT_RESOURCE_TYPE,
						hint_string="StyleBox",
						usage=51 if override else 18
					})

func _BuildCustomProperties(state : Dictionary) -> void:
	for cprop in _customs:
		match cprop.type:
			TYPE.Colors:
				state.colors.append(cprop.prop)
			TYPE.Constants:
				state.consts.append(cprop.prop)
			TYPE.Fonts:
				state.fonts.append(cprop.prop)
			TYPE.Icons:
				state.icons.append(cprop.prop)
			TYPE.Styles:
				state.styles.append(cprop.prop)

# -----------------------------------------------------------------------------
# Public Methods
# -----------------------------------------------------------------------------
func has_control_source(c : Control) -> bool:
	for cwr in _controls:
		if cwr.get_ref() == c:
			return true
	return false

func add_control_source(c : Control) -> void:
	if not has_control_source(c):
		var ref : WeakRef = weakref(c)
		_controls.append(ref)

func get_property_type(property : String) -> int:
	var info = _GetControlProperty(property)
	if info != null:
		return info.type
	return -1

func has_color_override(property : String) -> bool:
	for ref in _controls:
		var c : Control = ref.get_ref()
		if c:
			if c.has_color_override(property):
				return true
	return false

func add_color_override(property : String, value) -> void:
	if value != null and typeof(value) != TYPE_COLOR:
		return
	for ref in _controls:
		var c : Control = ref.get_ref()
		if not c:
			continue
		
		if _ControlHasProperty(c, TYPE.Colors, property):
			if value == null:
				property = "custom_colors/%s"%[property]
				c.set(property, null)
			else:
				c.add_color_override(property, value)
			return

func get_color(property : String) -> Color:
	for ref in _controls:
		var c : Control = ref.get_ref()
		if not c:
			continue
		
		if _ControlHasProperty(c, TYPE.Colors, property):
			if c.has_color_override(property):
				return c.get_color(property)
			elif theme_type != "" and c.has_color(property, theme_type):
				return c.get_color(property, theme_type)
			else:
				return c.get_color(property)
	return Color(0,0,0,1)

func has_constant_override(property : String) -> bool:
	for ref in _controls:
		var c : Control = ref.get_ref()
		if c:
			if c.has_constant_override(property):
				return true
	return false

func add_constant_override(property : String, value) -> void:
	if value != null and typeof(value) != TYPE_INT:
		return
	for ref in _controls:
		var c : Control = ref.get_ref()
		if not c:
			continue
		
		if _ControlHasProperty(c, TYPE.Constants, property):
			if value == null:
				property = "custom_constants/%s"%[property]
				c.set(property, null)
			else:
				c.add_constant_override(property, value)
			return

func get_constant(property : String) -> int:
	for ref in _controls:
		var c : Control = ref.get_ref()
		if not c:
			continue
		
		if _ControlHasProperty(c, TYPE.Constants, property):
			if c.has_constant_override(property):
				return c.get_constant(property)
			elif theme_type != "" and c.has_constant(property, theme_type):
				return c.get_constant(property, theme_type)
			else:
				return c.get_constant(property)
	return 0

func has_font_override(property : String) -> bool:
	for ref in _controls:
		var c : Control = ref.get_ref()
		if c:
			if c.has_font_override(property):
				return true
	return false

func add_font_override(property : String, value) -> void:
	if value != null and not (value is Font):
		return
	for ref in _controls:
		var c : Control = ref.get_ref()
		if not c:
			continue
		
		if _ControlHasProperty(c, TYPE.Fonts, property):
			if value == null:
				property = "custom_fonts/%s"%[property]
				c.set(property, null)
			else:
				c.add_font_override(property, value)
			return

func get_font(property : String) -> Font:
	for ref in _controls:
		var c : Control = ref.get_ref()
		if not c:
			continue
		
		if _ControlHasProperty(c, TYPE.Fonts, property):
			if c.has_font_override(property):
				return c.get_font(property)
			elif theme_type != "" and c.has_font(property, theme_type):
				return c.get_font(property, theme_type)
			else:
				return c.get_font(property)
	return null

func has_icon_override(property : String) -> bool:
	for ref in _controls:
		var c : Control = ref.get_ref()
		if c:
			if c.has_icon_override(property):
				return true
	return false

func add_icon_override(property : String, value) -> void:
	if value != null and not (value is Texture):
		return
	for ref in _controls:
		var c : Control = ref.get_ref()
		if not c:
			continue
		
		if _ControlHasProperty(c, TYPE.Icons, property):
			if value == null:
				property = "custom_icons/%s"%[property]
				c.set(property, null)
			else:
				c.add_icon_override(property, value)
			return

func get_icon(property : String) -> Texture:
	for ref in _controls:
		var c : Control = ref.get_ref()
		if not c:
			continue
		
		if _ControlHasProperty(c, TYPE.Fonts, property):
			if c.has_icon_override(property):
				return c.get_icon(property)
			elif theme_type != "" and c.has_icon(property, theme_type):
				return c.get_icon(property, theme_type)
			else:
				return c.get_icon(property)
	return null

func has_stylebox_override(property : String) -> bool:
	for ref in _controls:
		var c : Control = ref.get_ref()
		if c:
			if c.has_stylebox_override(property):
				return true
	return false

func add_stylebox_override(property : String, value) -> void:
	if value != null and not (value is StyleBox):
		return
	for ref in _controls:
		var c : Control = ref.get_ref()
		if not c:
			continue
		
		if _ControlHasProperty(c, TYPE.Styles, property):
			if value == null:
				property = "custom_styles/%s"%[property]
				c.set(property, null)
			else:
				c.add_stylebox_override(property, value)
			return

func get_stylebox(property : String) -> StyleBox:
	for ref in _controls:
		var c : Control = ref.get_ref()
		if not c:
			continue
		
		if _ControlHasProperty(c, TYPE.Fonts, property):
			if c.has_stylebox_override(property):
				return c.get_stylebox(property)
			elif theme_type != "" and c.has_stylebox(property, theme_type):
				return c.get_stylebox(property, theme_type)
			else:
				return c.get_stylebox(property)
	return null

func get_property(property : String):
	var type : int = get_property_type(property)
	if type >= 0:
		match type:
			TYPE.Colors:
				if has_color_override(property):
					return get_color(property)
			TYPE.Constants:
				if has_constant_override(property):
					return get_constant(property)
			TYPE.Fonts:
				if has_font_override(property):
					return get_font(property)
			TYPE.Icons:
				if has_icon_override(property):
					return get_icon(property)
			TYPE.Styles:
				if has_stylebox_override(property):
					return get_stylebox(property)
	return null

func set_property(property : String, value) -> bool:
	var type : int = get_property_type(property)
	if type >= 0:
		match type:
			TYPE.Colors:
				if value == null or typeof(value) == TYPE_COLOR:
					add_color_override(property, value)
					return true
			TYPE.Constants:
				if value == null or typeof(value) == TYPE_INT:
					add_constant_override(property, value)
					return true
			TYPE.Fonts:
				if value == null or value is Font:
					add_font_override(property, value)
					return true
			TYPE.Icons:
				if value == null or value is Texture:
					add_icon_override(property, value)
					return true
			TYPE.Styles:
				if value == null or value is StyleBox:
					add_stylebox_override(property, value)
					return true
	return false

func add_custom_property(type : int, property : String, prop_type : int, checked : bool = false, hint : int = 0, hint_string : String = "") -> void:
	if not property in _customs:
		_customs[property] = {
			"type":type,
			"prop":{
				name=property,
				type=prop_type,
				hint=hint,
				hint_string=hint_string,
				usage=51 if checked else 18
			}
		}

func inject_theme_property_list(arr : Array) -> Array:
	var state : Dictionary = {
		"colors": [{
			name="theme_overrides/colors",
			type=TYPE_NIL,
			usage=PROPERTY_USAGE_GROUP
		}],
		"consts": [{
			name="theme_overrides/constants",
			type=TYPE_NIL,
			usage=PROPERTY_USAGE_GROUP
		}],
		"fonts": [{
			name="theme_overrides/fonts",
			type=TYPE_NIL,
			usage=PROPERTY_USAGE_GROUP
		}],
		"icons": [{
			name="theme_overrides/icons",
			type=TYPE_NIL,
			usage=PROPERTY_USAGE_GROUP
		}],
		"styles": [{
			name="theme_overrides/styles",
			type=TYPE_NIL,
			usage=PROPERTY_USAGE_GROUP
		}]
	}
	
	_BuildControlProperties(state)
	_BuildCustomProperties(state)
	_customs.clear()
	arr.append_array(state.colors)
	arr.append_array(state.consts)
	arr.append_array(state.fonts)
	arr.append_array(state.icons)
	arr.append_array(state.styles)
	return arr
