extends RefCounted
## Testa o caminho de entrada: Input Map, movimento, mouse, raycast do Interactor,
## atalhos do HUD (F1/F3) e encerramento de dia de debug (F4).
## Usa chamadas diretas nos métodos de input para não depender de janela.

const MAIN_PATH := "res://cenas/main/Main.tscn"


func run(t) -> void:
	for action in [
		"move_forward", "move_back", "move_left", "move_right",
		"interact", "toggle_subtitle", "toggle_fps", "pause", "debug_finish_day",
	]:
		t.check(InputMap.has_action(action), "Input Map tem a ação '%s'" % action)

	var energy: Node = t.root.get_node("EnergyManager")
	var dialogue: Node = t.root.get_node("DialogueManager")
	var game_state: Node = t.root.get_node("GameState")

	var main = (load(MAIN_PATH) as PackedScene).instantiate()
	t.root.add_child(main)
	await t.process_frame
	main.start_game()
	await t.process_frame
	dialogue.stop()

	var player = main.get_node("%Player")
	var cam = player.get_node("%Camera3D")
	var inter = player.get_node("%Interactor")
	var hud = main.get_node("%HUD")
	var lamp = main.get_node("SalaEstar/LampadaSala")

	# WASD: o corpo precisa estar assentado antes de medir, senão o primeiro
	# passo gasta a ação ejetando a cápsula que nasceu dentro do piso.
	await assentar_no_piso(t, player)

	# WASD: medimos a distância horizontal coberta em 12 passos de física.
	# Não chamamos _physics_process à mão: move_and_slide() lê o estado de
	# colisão que o servidor de física só sincroniza no passo real do engine,
	# então chamadas manuais liam contatos defasados — em headless isso
	# derrubava o deslocamento de 0,85 m para ~0,08 m em execuções aleatórias.
	# Await de physics_frame deixa o engine dar os passos, um por iteração.
	var start: Vector3 = player.global_position
	Input.action_press("move_forward")
	for i in 12:
		await t.physics_frame
	Input.action_release("move_forward")
	var deslocamento: Vector2 = Vector2(
		player.global_position.x - start.x,
		player.global_position.z - start.z
	)
	t.check(
		deslocamento.length() > 0.1,
		"W move o jogador para frente (%.3f m no plano horizontal)" % deslocamento.length()
	)

	# mouse olha (só quando capturado; em headless o modo pode não persistir)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var before_yaw: float = player.rotation.y
		var motion := InputEventMouseMotion.new()
		motion.relative = Vector2(80, 0)
		player._unhandled_input(motion)
		t.check(not is_equal_approx(player.rotation.y, before_yaw), "mouse gira a câmera")

	# mira a lâmpada e aperta E via Interactor
	# Encerra qualquer diálogo antes do teste de interação: com awaits reais de
	# física, a sequência da Main (Timer de 0,35 s) avança para o próximo
	# diálogo, e o Interactor ignora o E enquanto não houver objetivo pendente.
	dialogue.stop()
	player.global_position = Vector3(1.35, 0.05, -0.25)
	player.rotation.y = -0.7
	cam.rotation.x = -0.3
	inter.force_raycast_update()
	inter._physics_process(0.0)
	t.check(inter.current_target == lamp, "raycast detecta a lâmpada")
	if inter.current_target == lamp:
		var press := InputEventAction.new()
		press.action = "interact"
		press.pressed = true
		inter._unhandled_input(press)
		t.check(energy.get_state("lampada_sala") == "off", "E desliga o dispositivo mirado")
		inter.force_raycast_update()
		inter._physics_process(0.0)
		var prompt_depois: String = hud.get_node("%PromptEN").text
		t.check(prompt_depois.contains("turn on"), "prompt troca para a próxima ação (turn on)")

	# F1 alterna legenda
	var before_mode := str(game_state.subtitle_mode)
	var subtitle_event := InputEventAction.new()
	subtitle_event.action = "toggle_subtitle"
	subtitle_event.pressed = true
	hud._unhandled_input(subtitle_event)
	t.check(str(game_state.subtitle_mode) != before_mode, "F1 alterna o modo de legenda")

	# F3 alterna FPS
	var fps_label = hud.get_node_or_null("%FPS")
	if fps_label != null:
		var before_fps: bool = fps_label.visible
		var fps_event := InputEventAction.new()
		fps_event.action = "toggle_fps"
		fps_event.pressed = true
		hud._unhandled_input(fps_event)
		t.check(fps_label.visible != before_fps, "F3 alterna o overlay de FPS")

	# F4 encerra o dia (debug de apresentação)
	var finish_event := InputEventAction.new()
	finish_event.action = "debug_finish_day"
	finish_event.pressed = true
	main._unhandled_input(finish_event)
	t.check(energy.day_ended, "F4 encerra o dia para a apresentação")

	player.set_physics_process(true)
	main.free()
	energy.start_day()
	dialogue.reload()


# Espera o corpo encostar no piso antes de medir movimento. O spawn deixa a
# cápsula um pouco dentro do solo, e o solver gasta o primeiro passo a ejetá-la;
# sem este passo prévio a distância medida variava entre execuções.
func assentar_no_piso(t, player) -> void:
	for i in 40:
		if player.is_on_floor():
			return
		await t.physics_frame
