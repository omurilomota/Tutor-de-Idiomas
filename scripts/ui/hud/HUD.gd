extends CanvasLayer
## HUD principal: relógio, consumo ao vivo, custo, CO₂, dispositivos,
## prompt de interação, objetivo atual e medidor de FPS (F3).

@onready var relogio: Label = %Relogio
@onready var kw: Label = %KW
@onready var kwh: Label = %KWh
@onready var custo: Label = %Custo
@onready var co2: Label = %CO2
@onready var lista_dispositivos: VBoxContainer = %ListaDispositivos
@onready var prompt_en: Label = %PromptEN
@onready var prompt_pt: Label = %PromptPT
@onready var objetivo: Label = %Objetivo
@onready var objetivo_painel: Control = get_node_or_null("%ObjetivoPainel")
@onready var prompt_painel: Control = get_node_or_null("%PromptPainel")
@onready var legenda: Label = %Legenda
@onready var fps: Label = get_node_or_null("%FPS")

var _device_labels: Dictionary = {}
var _fps_timer: float = 0.0


func _ready() -> void:
	EnergyManager.energy_updated.connect(_on_energy_updated)
	EnergyManager.clock_updated.connect(_on_clock_updated)
	EnergyManager.device_changed.connect(_on_device_changed)
	DialogueManager.objective_requested.connect(_on_objective_requested)
	DialogueManager.objective_completed.connect(_on_objective_completed)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	GameState.subtitle_mode_changed.connect(_on_subtitle_mode_changed)
	_build_device_list()
	_refresh_all()
	clear_prompt()
	set_objetivo("")
	if fps != null:
		fps.hide()
	_update_subtitle_hint()


func _process(delta: float) -> void:
	if fps == null or not fps.visible:
		return
	_fps_timer += delta
	if _fps_timer >= 0.25:
		_fps_timer = 0.0
		fps.text = "FPS: %d" % Engine.get_frames_per_second()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_subtitle"):
		GameState.cycle_subtitle_mode()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_fps") and fps != null:
		fps.visible = not fps.visible
		get_viewport().set_input_as_handled()


func on_target_changed(_target: Node, en: String, pt: String) -> void:
	if en.is_empty():
		clear_prompt()
		return
	prompt_en.text = en
	prompt_pt.text = pt
	if prompt_painel != null:
		prompt_painel.show()


func clear_prompt() -> void:
	prompt_en.text = ""
	prompt_pt.text = ""
	if prompt_painel != null:
		prompt_painel.hide()


func set_objetivo(text: String) -> void:
	objetivo.text = text
	objetivo.visible = not text.is_empty()
	if objetivo_painel != null:
		objetivo_painel.visible = not text.is_empty()


func _on_energy_updated(kwh_value: float, cost_brl: float, co2_kg: float, kw_now: float) -> void:
	kw.text = "%.2f kW" % kw_now
	kwh.text = "%.3f kWh" % kwh_value
	custo.text = "R$ %.2f" % cost_brl
	co2.text = "%.3f kg CO₂" % co2_kg


func _on_clock_updated(clock_minutes: int) -> void:
	relogio.text = EnergyManager.format_clock(clock_minutes)


func _on_device_changed(device_id: String, _is_on: bool, _watts: float) -> void:
	if not _device_labels.has(device_id):
		return
	_refresh_device_label(device_id)


func _build_device_list() -> void:
	for child in lista_dispositivos.get_children():
		lista_dispositivos.remove_child(child)
		child.queue_free()
	_device_labels.clear()
	for device_id in EnergyManager.devices.keys():
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 15)
		lista_dispositivos.add_child(label)
		_device_labels[device_id] = label
		_refresh_device_label(device_id)


func _refresh_device_label(device_id: String) -> void:
	if not _device_labels.has(device_id):
		return
	var device = EnergyManager.get_device(device_id)
	if device == null:
		return
	var label: Label = _device_labels[device_id]
	var state := "OFF"
	match device.state_name():
		"on":
			state = "ON"
		"eco":
			state = "ECO"
	label.text = "%s — %s · %.0f W" % [
		device.nome_pt,
		state,
		device.current_watts(),
	]
	label.modulate = Color(0.6, 0.9, 0.7) if device.is_on else Color(0.78, 0.8, 0.84)


func _refresh_all() -> void:
	kw.text = "%.2f kW" % EnergyManager.get_kw_now()
	kwh.text = "%.3f kWh" % EnergyManager.kwh
	var tariff := float(EnergyManager.config.get("tarifa_brl_kwh", 0.75))
	var co2_factor := float(EnergyManager.config.get("co2_kg_por_kwh", 0.084))
	custo.text = "R$ %.2f" % (EnergyManager.kwh * tariff)
	co2.text = "%.3f kg CO₂" % (EnergyManager.kwh * co2_factor)
	relogio.text = EnergyManager.format_clock(EnergyManager.clock_minutes)
	for device_id in _device_labels.keys():
		_refresh_device_label(device_id)


func _on_objective_requested(device_id: String, state: String) -> void:
	var device = EnergyManager.get_device(device_id)
	var nome_pt := device_id
	var nome_en := device_id
	if device != null:
		nome_pt = str(device.nome_pt)
		nome_en = str(device.nome_en)
	var verbo_pt := "desligar"
	var verbo_en := "turn off"
	match state:
		"on":
			verbo_pt = "ligar"
			verbo_en = "turn on"
		"eco":
			verbo_pt = "modo eco em"
			verbo_en = "set eco mode on"
	set_objetivo("Objetivo: %s — %s\nGoal: %s — %s" % [verbo_pt, nome_pt, verbo_en, nome_en])


func _on_objective_completed(_device_id: String) -> void:
	set_objetivo("")


func _on_dialogue_finished(_dialogue_id: String) -> void:
	set_objetivo("")


func _on_subtitle_mode_changed(_mode: String) -> void:
	_update_subtitle_hint()


func _update_subtitle_hint() -> void:
	legenda.text = "F1 — legenda: %s" % GameState.subtitle_mode
