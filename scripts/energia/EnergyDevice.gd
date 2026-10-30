extends RefCounted
## Um dispositivo consumidor de energia da casa.
## Instanciado por EnergyManager a partir de dados/dispositivos.json.

var id: String = ""
var nome_pt: String = ""
var nome_en: String = ""
var comodo: String = "sala"
var watt_on: float = 0.0
var watt_standby: float = 0.0
var watt_eco: float = 0.0
var is_on: bool = false
var initial_on: bool = false
var mode: String = "normal"


func _init(data: Dictionary = {}) -> void:
	id = str(data.get("id", ""))
	nome_pt = str(data.get("nome_pt", id))
	nome_en = str(data.get("nome_en", id))
	comodo = str(data.get("comodo", "sala"))
	watt_on = float(data.get("watt_on", 0.0))
	watt_standby = float(data.get("watt_standby", 0.0))
	watt_eco = float(data.get("watt_eco", 0.0))
	initial_on = bool(data.get("ligado_inicial", false))
	is_on = initial_on


func reset() -> void:
	is_on = initial_on
	mode = "normal"


func supports_eco() -> bool:
	return watt_eco > 0.0 and watt_eco < watt_on


func current_watts() -> float:
	if not is_on:
		return watt_standby
	if mode == "eco" and supports_eco():
		return watt_eco
	return watt_on


func set_state(state: String) -> bool:
	match state:
		"on":
			is_on = true
			mode = "normal"
		"off":
			is_on = false
			mode = "normal"
		"eco":
			if not supports_eco():
				return false
			is_on = true
			mode = "eco"
		_:
			return false
	return true


func state_name() -> String:
	if not is_on:
		return "off"
	return "eco" if mode == "eco" else "on"


func next_state() -> String:
	if supports_eco():
		match state_name():
			"on":
				return "eco"
			"eco":
				return "off"
			_:
				return "on"
	return "off" if is_on else "on"


func to_dict() -> Dictionary:
	return {
		"id": id,
		"nome_pt": nome_pt,
		"nome_en": nome_en,
		"comodo": comodo,
		"ligado": is_on,
		"modo": state_name(),
		"watts": current_watts(),
	}
