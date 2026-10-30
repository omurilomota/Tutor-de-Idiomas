extends RefCounted
## Partida completa: Main inicia o dia/diálogo, HUD reage ao objetivo,
## o fim do dia abre o relatório e o botão reiniciar recomeça sem recarregar.

const MAIN_PATH := "res://cenas/main/Main.tscn"


func run(t) -> void:
	var energy: Node = t.root.get_node("EnergyManager")
	var dialogue: Node = t.root.get_node("DialogueManager")

	var packed = load(MAIN_PATH)
	t.check(packed != null, "Main carrega para a partida")
	if packed == null:
		return
	var main = packed.instantiate()
	t.root.add_child(main)

	main.start_game()
	t.check(energy.running, "start_game inicia o dia")
	t.check(not energy.day_ended, "dia começa aberto")
	t.check(dialogue.active, "partida começa com diálogo")
	t.check(str(dialogue.current_id) == "sala_01", "primeiro diálogo é sala_01")
	t.check(energy.paused, "relógio pausado durante o diálogo")

	var caixa = main.get_node_or_null("%CaixaDialogo")
	t.check(caixa != null and caixa.visible, "caixa de diálogo aparece")
	var hud = main.get_node_or_null("%HUD")
	t.check(hud != null, "HUD existe na partida")

	# intro → pedido_luz → objetivo_luz
	dialogue.choose(0)
	t.check(str(dialogue.current_node_id) == "pedido_luz", "escolha leva ao pedido da luz")
	dialogue.choose(0)
	t.check(dialogue.waiting_objective, "diálogo trava no objetivo físico")
	if hud != null:
		var objetivo = hud.get_node_or_null("%Objetivo")
		t.check(objetivo != null and objetivo.text.contains("desligar"), "HUD mostra o objetivo em PT")
		t.check(objetivo.text.contains("turn off"), "HUD mostra o objetivo em EN")

	energy.set_device_state("lampada_sala", "off")
	t.check(not dialogue.waiting_objective, "ação física libera o diálogo")
	t.check(energy.vocabulary.size() >= 2, "ação desbloqueia vocabulário")

	# fim do dia
	energy.finish_day()
	t.check(energy.day_ended, "fim do dia marca day_ended")
	t.check(not dialogue.active, "fim do dia fecha o diálogo")
	t.check(not energy.paused, "fim do dia libera a pausa")

	var relatorio = main.get_node_or_null("%TelaRelatorio")
	t.check(relatorio != null and relatorio.visible, "relatório aparece no fim do dia")
	if relatorio != null:
		var nota = relatorio.get_node_or_null("%Nota")
		t.check(nota != null and not nota.text.is_empty(), "relatório mostra a nota")
		var resumo = relatorio.get_node_or_null("%Resumo")
		t.check(resumo != null and resumo.text.contains("Baseline"), "relatório mostra o baseline")
		var vocab = relatorio.get_node_or_null("%Vocabulario")
		t.check(vocab != null and vocab.text.contains("turn off the light"), "relatório lista o vocabulário")

		# reiniciar sem trocar de cena
		var botao = relatorio.get_node_or_null("%BotaoReiniciar")
		t.check(botao != null, "relatório tem botão reiniciar")
		if botao != null:
			botao.pressed.emit()

	t.check(not energy.day_ended, "reiniciar reabre o dia")
	t.check(energy.running, "reiniciar religa a simulação")
	t.check(dialogue.active, "reiniciar recomeça o diálogo")
	t.check(str(dialogue.current_id) == "sala_01", "reiniciar volta ao primeiro diálogo")
	if relatorio != null:
		t.check(not relatorio.visible, "reiniciar esconde o relatório")
	t.check(energy.get_state("lampada_sala") == "on", "reiniciar restaura os dispositivos")

	# Libera a Main antes de encerrar o diálogo: o handler de
	# dialogue_finished agenda um SceneTreeTimer de 0,35 s que sobreviveria ao nó.
	main.free()
	dialogue.stop()
	energy.start_day()
	dialogue.reload()
