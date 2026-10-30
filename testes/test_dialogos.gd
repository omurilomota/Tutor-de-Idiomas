extends RefCounted
## Testes do formato de diálogo e do conteúdo do MVP (4 árvores, ≥25 palavras).

const Validator = preload("res://scripts/dialogos/DialogueValidator.gd")
const Loader = preload("res://scripts/dialogos/DialogueLoader.gd")

const DEVICE_IDS := ["lampada_sala", "tv_sala", "ar_sala", "tomada_carregador"]
const DIALOGUE_IDS := ["sala_01", "sala_02", "sala_03", "sala_04"]


func run(t) -> void:
	_testa_conteudo_do_mvp(t)
	_testa_vocabulario(t)
	_testa_erros_esperados(t)


func _testa_conteudo_do_mvp(t) -> void:
	var all_dialogues := Loader.load_directory("res://dialogos")
	t.check(
		all_dialogues.size() == DIALOGUE_IDS.size(),
		"pasta dialogos/ contém %d diálogos (schema.json é ignorado)" % DIALOGUE_IDS.size()
	)

	for dialogue_id in DIALOGUE_IDS:
		t.check(all_dialogues.has(dialogue_id), "%s carrega" % dialogue_id)
		if not all_dialogues.has(dialogue_id):
			continue
		var dialogue: Dictionary = all_dialogues[dialogue_id]
		t.check(str(dialogue.get("id", "")) == dialogue_id, "id de %s é o nome do arquivo" % dialogue_id)
		var errors: Array = Validator.validate(dialogue, DEVICE_IDS)
		t.check(errors.is_empty(), "%s válido: %s" % [dialogue_id, str(errors)])

		var nodes: Dictionary = dialogue.get("nodes", {})
		t.check(nodes.size() >= 6, "%s tem pelo menos 6 nós" % dialogue_id)
		t.check(nodes.has(str(dialogue.get("start", ""))), "%s: nó inicial existe" % dialogue_id)

		var objectives := 0
		var ends := 0
		for node in nodes.values():
			if typeof(node) != TYPE_DICTIONARY:
				continue
			if node.has("objective"):
				objectives += 1
			if bool(node.get("end", false)):
				ends += 1
		t.check(objectives >= 1, "%s tem objetivo físico" % dialogue_id)
		t.check(ends >= 1, "%s termina em nó 'end'" % dialogue_id)
		if dialogue_id == "sala_01":
			t.check(nodes.size() >= 10, "sala_01 tem pelo menos 10 nós")
			t.check(objectives == 3, "sala_01 tem 3 objetivos físicos (luz, TV, ar)")


func _testa_vocabulario(t) -> void:
	var all_dialogues := Loader.load_directory("res://dialogos")
	var unique: Dictionary = {}
	for dialogue in all_dialogues.values():
		for node in dialogue.get("nodes", {}).values():
			if typeof(node) != TYPE_DICTIONARY:
				continue
			for entry in node.get("vocab", []):
				if typeof(entry) == TYPE_DICTIONARY:
					var key := str(entry.get("en", ""))
					if not key.is_empty():
						unique[key] = str(entry.get("pt", ""))
	t.check(unique.size() >= 25, "glossário tem ≥25 palavras/frases (tem %d)" % unique.size())
	t.check(unique.has("turn off the TV"), "glossário inclui 'turn off the TV'")
	t.check(unique.has("eco mode"), "glossário inclui 'eco mode'")
	t.check(unique.has("kilowatt-hour"), "glossário inclui 'kilowatt-hour'")


func _testa_erros_esperados(t) -> void:
	var next_inexistente := {
		"id": "quebrado_1",
		"start": "a",
		"nodes": {
			"a": {
				"speaker": "Alex",
				"en": "Hello",
				"pt": "Olá",
				"next": "nao_existe",
			}
		},
	}
	t.check(
		not Validator.validate(next_inexistente, DEVICE_IDS).is_empty(),
		"detecta 'next' apontando para nó inexistente"
	)

	var sem_saida := {
		"id": "quebrado_2",
		"start": "a",
		"nodes": {
			"a": {"speaker": "Alex", "en": "Hello", "pt": "Olá"}
		},
	}
	t.check(
		not Validator.validate(sem_saida, DEVICE_IDS).is_empty(),
		"detecta nó sem saída"
	)

	var dispositivo_invalido := {
		"id": "quebrado_3",
		"start": "a",
		"nodes": {
			"a": {
				"speaker": "Alex",
				"en": "Turn it off",
				"pt": "Desligue",
				"objective": {"device": "fogao", "state": "off"},
				"next": "b",
			},
			"b": {"speaker": "Alex", "en": "Done", "pt": "Pronto", "end": true},
		},
	}
	t.check(
		not Validator.validate(dispositivo_invalido, DEVICE_IDS).is_empty(),
		"detecta objective.device desconhecido"
	)

	var orfao := {
		"id": "quebrado_4",
		"start": "a",
		"nodes": {
			"a": {"speaker": "Alex", "en": "Hi", "pt": "Oi", "end": true},
			"b": {"speaker": "Alex", "en": "Lost", "pt": "Perdido", "end": true},
		},
	}
	t.check(
		not Validator.validate(orfao, DEVICE_IDS).is_empty(),
		"detecta nó órfão"
	)

	var texto_vazio := {
		"id": "quebrado_5",
		"start": "a",
		"nodes": {
			"a": {"speaker": "Alex", "en": "", "pt": "Oi", "end": true}
		},
	}
	t.check(
		not Validator.validate(texto_vazio, DEVICE_IDS).is_empty(),
		"detecta texto em inglês vazio"
	)
