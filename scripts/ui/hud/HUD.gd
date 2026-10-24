extends CanvasLayer
## HUD principal: relógio, consumo ao vivo, custo, CO₂ e lista de dispositivos.

@onready var relogio: Label = %Relogio
@onready var kw: Label = %KW
@onready var kwh: Label = %KWh
@onready var custo: Label = %Custo
@onready var co2: Label = %CO2
@onready var lista_dispositivos: VBoxContainer = %ListaDispositivos

var _device_labels: Dictionary = {}


func _ready() -> void:
	EnergyManager.energy_updated.connect(_on_energy_updated)
	EnergyManager.clock_updated.connect(_on_clock_updated)
	EnergyManager.device_changed.connect(_on_device_changed)
	_build_device_list()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_subtitle"):
		GameState.cycle_subtitle_mode()


func _on_energy_updated(kwh_value: float, cost_brl: float, co2_kg: float, kw_now: float) -> void:
	kw.text = "%.2f kW" % kw_now
	kwh.text = "%.3f kWh" % kwh_value
	custo.text = "R$ %.2f" % cost_brl
	co2.text = "%.3f kg CO₂" % co2_kg


func _on_clock_updated(clock_minutes: int) -> void:
	relogio.text = EnergyManager.format_clock(clock_minutes)


func _on_device_changed(device_id: String, is_on: bool, watts: float) -> void:
	if not _device_labels.has(device_id):
		return
	var device = EnergyManager.get_device(device_id)
	var label: Label = _device_labels[device_id]
	var state := "ON" if is_on else "OFF"
	if device != null and device.state_name() == "eco":
		state = "ECO"
	label.text = "%s — %s (%.0f W)" % [device.nome_pt if device != null else device_id, state, watts]


func _build_device_list() -> void:
	for child in lista_dispositivos.get_children():
		child.queue_free()
	_device_labels.clear()
	for device_id in EnergyManager.devices.keys():
		var device = EnergyManager.get_device(device_id)
		var label := Label.new()
		label.text = "%s — %.0f W" % [device.nome_pt, device.current_watts()]
		lista_dispositivos.add_child(label)
		_device_labels[device_id] = label
