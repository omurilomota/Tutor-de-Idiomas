extends Control
## Tela de fim de dia: economia vs baseline, custo/CO₂ evitados, vocabulário e nota.

@onready var nota: Label = %Nota
@onready var resumo: Label = %Resumo
@onready var vocabulario: Label = %Vocabulario
@onready var botao_reiniciar: Button = %BotaoReiniciar


func _ready() -> void:
	EnergyManager.day_finished.connect(_on_day_finished)
	botao_reiniciar.pressed.connect(_on_restart_pressed)
	hide()


func _on_day_finished(report: Dictionary) -> void:
	show()
	nota.text = "Nota: %s" % report.get("nota", "-")
	resumo.text = (
		"Você consumiu %.3f kWh (baseline %.3f kWh)\n"
		+ "Economia: %.1f%%  |  R$ %.2f  |  %.3f kg CO₂ evitados"
	) % [
		report.get("kwh_jogador", 0.0),
		report.get("kwh_baseline", 0.0),
		report.get("economia_pct", 0.0),
		report.get("custo_evitado_brl", 0.0),
		report.get("co2_evitado_kg", 0.0),
	]
	var words: Array = []
	for entry in report.get("vocabulario", []):
		words.append(str(entry.get("en", "")))
	vocabulario.text = "Vocabulário: " + ", ".join(words)


func _on_restart_pressed() -> void:
	EnergyManager.start_day()
	hide()
