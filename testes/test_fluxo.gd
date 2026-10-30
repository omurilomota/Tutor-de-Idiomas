extends RefCounted
## Teste de integração: diálogo → objetivo físico → ação → avanço.
## Os autoloads são buscados em /root (o compilador do runner não conhece
## os identificadores globais, mas os nós existem quando o projeto roda).

const DIALOGUE_IDS := ["sala_01", "sala_02", "sala_03", "sala_04"]


func run(t) -> void:
	var energy: Node = t.root.get_node("EnergyManager")
	var dialogue: Node = t.root.get_node("DialogueManager")
	var game_state: Node = t.root.get_node("GameState")

	energy.start_day()
	dialogue.reload()

	_executa_sequencia(t, energy, dialogue)

	t.check(not dialogue.active, "sequência termina com diálogo fechado")
	t.check(not energy.paused, "tempo volta a correr ao fim do diálogo")
	t.check(energy.vocabulary.size() >= 25, "partida desbloqueia ≥25 palavras (tem %d)" % energy.vocabulary.size())
	t.check(game_state.vocabulary.size() >= 25, "GameState também registra o glossário")

	energy.set_paused(false)
	energy.finish_day()
	t.check(energy.day_ended, "fim do dia marca day_ended")
	t.check(not dialogue.active, "fim do dia fecha o diálogo")
	energy.start_day()
	t.check(not energy.day_ended, "reiniciar limpa day_ended")


func _executa_sequencia(t, energy: Node, dialogue: Node) -> void:
	for dialogue_id in DIALOGUE_IDS:
		var started: bool = dialogue.start(dialogue_id)
		t.check(started, "%s abre no fluxo integrado" % dialogue_id)
		if not started:
			continue
		t.check(energy.paused, "%s pausa o relógio" % dialogue_id)

		var guard := 0
		var wrong_checked := false
		while dialogue.active and guard < 80:
			guard += 1
			if dialogue.waiting_objective:
				var objective: Dictionary = dialogue.current_objective()
				var device_id := str(objective.get("device", ""))
				var target := str(objective.get("state", ""))
				t.check(not device_id.is_empty(), "%s: objetivo tem device" % dialogue_id)

				if not wrong_checked and dialogue_id == "sala_01":
					var wrong := "off" if target != "off" else "on"
					energy.set_device_state(device_id, wrong)
					t.check(
						dialogue.waiting_objective,
						"ação errada (%s) não avança o objetivo de %s" % [wrong, target]
					)
					wrong_checked = true

				energy.set_device_state(device_id, target)
				t.check(
					not dialogue.waiting_objective,
					"%s: estado %s conclui o objetivo" % [device_id, target]
				)
			elif dialogue.current_node.has("choices"):
				dialogue.choose(0)
			else:
				dialogue.advance()

		t.check(guard < 80, "%s termina sem loop infinito" % dialogue_id)
		t.check(not dialogue.active, "%s fecha ao chegar no nó final" % dialogue_id)
