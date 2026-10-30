extends RefCounted
## UI do diálogo: escolhas por teclado (1–4) e por clique, além do ciclo
## completo de legenda do F1 (EN+PT → EN → PT → EN+PT).

const MAIN_PATH := "res://cenas/main/Main.tscn"


func run(t) -> void:
	var energy: Node = t.root.get_node("EnergyManager")
	var dialogue: Node = t.root.get_node("DialogueManager")
	var game_state: Node = t.root.get_node("GameState")
	game_state.set_subtitle_mode("both")

	var main = (load(MAIN_PATH) as PackedScene).instantiate()
	t.root.add_child(main)
	await t.process_frame
	main.start_game()
	await t.process_frame

	var caixa = main.get_node("%CaixaDialogo")
	var hud = main.get_node("%HUD")
	t.check(caixa.visible, "a caixa aparece no primeiro diálogo")
	t.check(str(dialogue.current_node_id) == "intro", "UI começa no nó intro")

	# Teclado: no nó intro, a opção 2 leva ao nó de ajuda.
	caixa._finish_typing()
	var lista = caixa.get_node("%ListaEscolhas")
	t.check(lista.get_child_count() == 2, "intro renderiza 2 escolhas")
	var tecla := InputEventKey.new()
	tecla.keycode = KEY_2
	tecla.pressed = true
	caixa._unhandled_input(tecla)
	t.check(str(dialogue.current_node_id) == "ajuda", "tecla 2 escolhe a segunda opção")

	# Avança a fala de ajuda e escolhe a primeira opção com clique.
	caixa._finish_typing()
	caixa._unhandled_input(_evento_acao("interact"))
	t.check(str(dialogue.current_node_id) == "pedido_luz", "E avança a fala sem escolhas")

	caixa._finish_typing()
	lista = caixa.get_node("%ListaEscolhas")
	t.check(lista.get_child_count() == 2, "pedido_luz renderiza 2 escolhas")
	if lista.get_child_count() > 0:
		var botao: Button = lista.get_child(0)
		t.check(botao.focus_mode == Control.FOCUS_ALL, "escolha é focável pelo teclado")
		botao.pressed.emit()
	t.check(str(dialogue.current_node_id) == "objetivo_luz", "clique escolhe a primeira opção")
	t.check(dialogue.waiting_objective, "diálogo espera a ação física")

	# Enquanto o objetivo está pendente, a caixa não consome o E.
	caixa._unhandled_input(_evento_acao("interact"))
	t.check(str(dialogue.current_node_id) == "objetivo_luz", "E não pula o objetivo pendente")

	# F1: os três modos precisam refletir na caixa.
	t.check(caixa.texto_en.visible and caixa.texto_pt.visible, "modo inicial mostra EN+PT")
	_toggle_f1(hud)
	t.check(str(game_state.subtitle_mode) == "en", "F1 vai para EN")
	t.check(caixa.texto_en.visible and not caixa.texto_pt.visible, "modo EN esconde o PT")
	_toggle_f1(hud)
	t.check(str(game_state.subtitle_mode) == "pt", "F1 vai para PT")
	t.check(not caixa.texto_en.visible and caixa.texto_pt.visible, "modo PT esconde o EN")
	_toggle_f1(hud)
	t.check(str(game_state.subtitle_mode) == "both", "F1 volta para EN+PT")
	t.check(caixa.texto_en.visible and caixa.texto_pt.visible, "modo both mostra as duas linhas")
	t.check(hud.get_node("%Legenda").text.contains("both"), "HUD mostra o modo de legenda")

	# Limpeza: libera a Main antes de encerrar o diálogo para não deixar
	# um SceneTreeTimer de transição vivo no shutdown. O await garante que
	# o nó saia da árvore antes da próxima suíte criar outro Player no spawn.
	main.free()
	await t.process_frame
	dialogue.stop()
	energy.start_day()
	dialogue.reload()
	game_state.set_subtitle_mode("both")
	await t.process_frame


func _toggle_f1(hud) -> void:
	var evento := InputEventAction.new()
	evento.action = "toggle_subtitle"
	evento.pressed = true
	hud._unhandled_input(evento)


func _evento_acao(action: String) -> InputEventAction:
	var evento := InputEventAction.new()
	evento.action = action
	evento.pressed = true
	return evento
