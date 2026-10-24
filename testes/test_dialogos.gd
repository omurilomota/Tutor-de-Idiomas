extends RefCounted
## Testes do formato de diálogo e do conteúdo do MVP.

const Validator = preload("res://scripts/dialogos/DialogueValidator.gd")
const Loader = preload("res://scripts/dialogos/DialogueLoader.gd")

const DEVICE_IDS := ["lampada_sala", "tv_sala", "ar_sala", "tomada_carregador"]


func run(t) -> void:
	_testa_dialogo_do_mvp(t)
	_testa_erros_esperados(t)


func _testa_dialogo_do_mvp(t) -> void:
	var dialogue := Loader.load_dialogue("res://dialogos/sala_01.json")
	t.check(not dialogue.is_empty(), "sala_01.json carrega")
	if dialogue.is_empty():
		return

	t.check(str(dialogue.get("id", "")) == "sala_01", "id do diálogo é sala_01")
	var errors: Array = Validator.validate(dialogue, DEVICE_IDS)
	t.check(errors.is_empty(), "sala_01.json válido: %s" % str(errors))

	var nodes: Dictionary = dialogue.get("nodes", {})
	t.check(nodes.size() >= 10, "sala_01.json tem pelo menos 10 nós")
	t.check(nodes.has(str(dialogue.get("start", ""))), "nó inicial existe")

	var objectives := 0
	for node in nodes.values():
		if typeof(node) == TYPE_DICTIONARY and node.has("objective"):
			objectives += 1
	t.check(objectives == 3, "sala_01.json tem 3 objetivos físicos (luz, TV, ar)")

	var all_dialogues := Loader.load_directory("res://dialogos")
	t.check(all_dialogues.size() == 1, "pasta dialogos/ contém só o diálogo do MVP (schema.json é ignorado)")
	t.check(all_dialogues.has("sala_01"), "loader indexa o diálogo pelo id")


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
