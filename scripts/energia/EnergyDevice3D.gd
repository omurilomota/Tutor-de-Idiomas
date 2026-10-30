extends StaticBody3D
## Dispositivo físico da casa: colisão, visual e interação com o EnergyManager.
## Cada instância recebe `device_id` (ver dados/dispositivos.json) e um filho
## chamado `Glow`, que fica visível quando o aparelho está ligado.
##
## Camada de colisão 2 = só o Interactor do jogador enxerga (o player anda na 1).

@export var device_id: String = ""

var _device = null

@onready var _glow: Node3D = get_node_or_null("Glow")


func _ready() -> void:
	collision_layer = 2
	collision_mask = 0
	if device_id.is_empty():
		push_error("EnergyDevice3D sem device_id: %s" % name)
		return
	_device = EnergyManager.get_device(device_id)
	if _device == null:
		push_error("Dispositivo desconhecido no mundo: %s" % device_id)
		return
	EnergyManager.device_changed.connect(_on_device_changed)
	_refresh()


func get_prompt_en() -> String:
	if _device == null:
		return ""
	return "E — %s" % _describe(str(_device.next_state()), true)


func get_prompt_pt() -> String:
	if _device == null:
		return ""
	return "E — %s" % _describe(str(_device.next_state()), false)


func interact() -> void:
	if _device == null or EnergyManager.day_ended:
		return
	EnergyManager.interact(device_id)


func _on_device_changed(changed_id: String, _is_on: bool, _watts: float) -> void:
	if changed_id == device_id:
		_refresh()


func _refresh() -> void:
	if _device == null:
		return
	if _glow != null:
		_glow.visible = _device.is_on


func _describe(state: String, english: bool) -> String:
	var nome: String = _device.nome_en if english else _device.nome_pt
	match state:
		"on":
			return ("turn on the %s" % nome.to_lower()) if english else ("ligar %s" % nome)
		"eco":
			return ("set eco mode (%.0f W)" % _device.watt_eco) if english \
				else ("modo eco (%.0f W)" % _device.watt_eco)
		_:
			return ("turn off the %s" % nome.to_lower()) if english else ("desligar %s" % nome)
