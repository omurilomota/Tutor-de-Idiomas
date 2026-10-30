extends Control
## Tela de fim de dia: economia vs baseline, custo/CO₂ evitados,
## dispositivos esquecidos, vocabulário e nota.

signal restart_requested

@onready var nota: Label = %Nota
@onready var resumo: Label = %Resumo
@onready var vocabulario: Label = %Vocabulario
@onready var dispositivos: Label = get_node_or_null("%Dispositivos")
@onready var botao_reiniciar: Button = %BotaoReiniciar


func _ready() -> void:
	EnergyManager.day_finished.connect(_on_day_finished)
	botao_reiniciar.pressed.connect(_on_restart_pressed)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		_on_restart_pressed()
		get_viewport().set_input_as_handled()


func _on_day_finished(report: Dictionary) -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	nota.text = "Nota %s" % str(report.get("nota", "-"))

	var player_kwh := float(report.get("kwh_jogador", 0.0))
	var base_kwh := float(report.get("kwh_baseline", 0.0))
	var pct := float(report.get("economia_pct", 0.0))
	var meta := float(report.get("meta_pct", 20.0))
	var status := "Meta atingida!" if pct >= meta else "Faltou %.1f%% para a meta." % (meta - pct)
	if player_kwh > base_kwh:
		status = "Você consumiu mais que o baseline."

	resumo.text = (
		"Consumo do jogador: %.3f kWh\n"
		+ "Baseline de desperdício: %.3f kWh\n"
		+ "Economia: %.1f%%  (%s)\n"
		+ "Custo evitado: R$ %.2f\n"
		+ "CO₂ evitado: %.3f kg"
	) % [
		player_kwh,
		base_kwh,
		pct,
		status,
		float(report.get("custo_evitado_brl", 0.0)),
		float(report.get("co2_evitado_kg", 0.0)),
	]

	if dispositivos != null:
		dispositivos.text = _forgotten_devices_text()

	var words: Array = []
	for entry in report.get("vocabulario", []):
		if typeof(entry) == TYPE_DICTIONARY:
			words.append("%s — %s" % [str(entry.get("en", "")), str(entry.get("pt", ""))])
	if words.is_empty():
		words.append("Nenhuma palavra nova nesta partida.")
	vocabulario.text = "Vocabulário da partida\n" + "\n".join(words)

	botao_reiniciar.grab_focus()


func _forgotten_devices_text() -> String:
	var left_on: Array = []
	for device in EnergyManager.devices.values():
		if device.is_on:
			left_on.append("%s (%.0f W)" % [device.nome_pt, device.current_watts()])
	if left_on.is_empty():
		return "Tudo desligado. Boa!"
	return "Ainda ligados: " + ", ".join(left_on)


func _on_restart_pressed() -> void:
	restart_requested.emit()
	hide()
