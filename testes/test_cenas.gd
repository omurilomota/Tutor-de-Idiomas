extends RefCounted
## Smoke test da cena jogável: carrega SalaEstar, Player e Main e confere
## que os 4 dispositivos, a câmera, o Interactor e a UI existem.
## Roda headless, sem renderização, em poucos segundos.

const SALA_PATH := "res://cenas/salas/SalaEstar.tscn"
const PLAYER_PATH := "res://cenas/player/Player.tscn"
const MAIN_PATH := "res://cenas/main/Main.tscn"


func run(t) -> void:
	var energy: Node = t.root.get_node("EnergyManager")
	var dialogue: Node = t.root.get_node("DialogueManager")

	_testa_sala(t, energy)
	_testa_player(t)
	_testa_main(t, energy)

	# Limpa o estado que a Main possa ter deixado nos autoloads.
	energy.start_day()
	dialogue.reload()


func _testa_sala(t, energy: Node) -> void:
	var sala := _instanciar(t, SALA_PATH, "SalaEstar carrega")
	if sala == null:
		return

	var device_ids: Array = []
	for child in sala.get_children():
		if child.has_method("get_prompt_en"):
			device_ids.append(str(child.get("device_id")))
	for expected in energy.devices.keys():
		t.check(device_ids.has(str(expected)), "sala contém o dispositivo '%s'" % expected)
	t.check(
		device_ids.size() == energy.devices.size(),
		"sala tem exatamente %d dispositivos" % energy.devices.size()
	)

	t.check(sala.get_node_or_null("%Spawn") != null, "sala tem spawn (%Spawn)")
	t.check(sala.get_node_or_null("Estrutura") != null, "sala tem colisão estática (Estrutura)")
	t.check(sala.get_node_or_null("Ambiente") != null, "sala tem WorldEnvironment")
	var triangulos := _contar_triangulos(sala)
	t.check(triangulos > 0, "sala tem geometria (%d triângulos)" % triangulos)
	t.check(triangulos < 50000, "sala fica abaixo do orçamento de 50k triângulos (%d)" % triangulos)

	var lamp = sala.get_node_or_null("LampadaSala")
	t.check(lamp != null, "sala tem a lâmpada")
	if lamp != null:
		t.check(not str(lamp.get_prompt_en()).is_empty(), "lâmpada expõe prompt em inglês")
		t.check(not str(lamp.get_prompt_pt()).is_empty(), "lâmpada expõe prompt em português")
		t.check(lamp.get_node_or_null("Glow") != null, "lâmpada tem nó Glow")
	sala.free()


func _testa_player(t) -> void:
	var player := _instanciar(t, PLAYER_PATH, "Player carrega")
	if player == null:
		return
	t.check(player is CharacterBody3D, "Player é CharacterBody3D")
	t.check(player.get_node_or_null("%Camera3D") != null, "Player expõe %Camera3D")
	var ray := player.get_node_or_null("%Interactor")
	t.check(ray is RayCast3D, "Player expõe %Interactor (RayCast3D)")
	if ray is RayCast3D:
		t.check(ray.collision_mask == 2, "Interactor enxerga só a camada de dispositivos")
		t.check(is_equal_approx(ray.target_position.z, -2.5), "Interactor tem alcance de 2,5 m")
	player.free()


func _testa_main(t, energy: Node) -> void:
	var main := _instanciar(t, MAIN_PATH, "Main carrega")
	if main == null:
		return

	t.check(main.get_node_or_null("%Player") != null, "Main tem %Player")
	t.check(main.get_node_or_null("%SalaEstar") != null, "Main tem %SalaEstar")
	t.check(main.get_node_or_null("%HUD") != null, "Main tem %HUD")
	t.check(main.get_node_or_null("%CaixaDialogo") != null, "Main tem %CaixaDialogo")
	t.check(main.get_node_or_null("%TelaRelatorio") != null, "Main tem %TelaRelatorio")

	var hud := main.get_node_or_null("%HUD")
	if hud != null:
		t.check(hud.get_node_or_null("%Relogio") != null, "HUD tem %Relogio")
		t.check(hud.get_node_or_null("%KW") != null, "HUD tem %KW")
		t.check(hud.get_node_or_null("%ListaDispositivos") != null, "HUD tem %ListaDispositivos")
		var lista := hud.get_node_or_null("%ListaDispositivos")
		if lista != null:
			t.check(
				lista.get_child_count() == energy.devices.size(),
				"HUD lista os %d dispositivos" % energy.devices.size()
			)

	var caixa := main.get_node_or_null("%CaixaDialogo")
	if caixa != null:
		for node_name in ["%Painel", "%Fala", "%TextoEN", "%TextoPT", "%ListaEscolhas", "%DicaContinuar"]:
			t.check(caixa.get_node_or_null(node_name) != null, "CaixaDialogo tem %s" % node_name)
		t.check(not caixa.visible, "caixa de diálogo começa escondida")

	var relatorio := main.get_node_or_null("%TelaRelatorio")
	if relatorio != null:
		for node_name in ["%Nota", "%Resumo", "%Vocabulario", "%BotaoReiniciar"]:
			t.check(relatorio.get_node_or_null(node_name) != null, "TelaRelatorio tem %s" % node_name)
		t.check(not relatorio.visible, "relatório começa escondido")

	var cartao = main.get_node("CamadaCartao").get_child(0)
	t.check(cartao.get_node_or_null("%TextoEN") != null, "cartão tem %TextoEN")
	t.check(not cartao.visible, "cartão começa escondido")

	main.free()


func _contar_triangulos(node: Node) -> int:
	var total := 0
	if node is MeshInstance3D and node.mesh != null:
		total += node.mesh.get_faces().size() / 3
	for child in node.get_children():
		total += _contar_triangulos(child)
	return total


func _instanciar(t, path: String, descricao: String) -> Node:
	var packed = load(path)
	t.check(packed != null, descricao + " (recurso existe)")
	if packed == null:
		return null
	var instance = packed.instantiate()
	t.check(instance != null, descricao + " (instancia)")
	if instance == null:
		return null
	t.root.add_child(instance)
	return instance
