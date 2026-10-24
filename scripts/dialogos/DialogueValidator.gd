extends RefCounted
## Validação do formato dos diálogos (dialogos/*.json).
## Retorna uma lista de erros legíveis; lista vazia significa diálogo válido.

const MAX_CHOICES := 4
const VALID_STATES: Array[String] = ["on", "off", "eco"]
const REQUIRED_TEXT_FIELDS: Array[String] = ["speaker", "en", "pt"]


static func validate(dialogue: Dictionary, device_ids: Array) -> Array:
	var errors: Array = []

	for field in ["id", "start", "nodes"]:
		if not dialogue.has(field):
			errors.append("campo obrigatório ausente: %s" % field)
	if not errors.is_empty():
		return errors

	var nodes: Dictionary = dialogue.get("nodes", {})
	var start := str(dialogue.get("start", ""))
	if nodes.is_empty():
		errors.append("nenhum nó definido em 'nodes'")
		return errors
	if not nodes.has(start):
		errors.append("nó inicial '%s' não existe" % start)

	var reachable: Dictionary = {}
	for node_id in nodes.keys():
		var node = nodes[node_id]
		if typeof(node) != TYPE_DICTIONARY:
			errors.append("nó '%s' não é um objeto JSON" % node_id)
			continue
		errors.append_array(_validate_node(str(node_id), node, nodes, device_ids))

	if nodes.has(start):
		_collect_reachable(str(start), nodes, reachable)
		for node_id in nodes.keys():
			if not reachable.has(str(node_id)):
				errors.append("nó órfão (inacessível a partir de '%s'): %s" % [start, node_id])

	return errors


static func _validate_node(
	node_id: String,
	node: Dictionary,
	nodes: Dictionary,
	device_ids: Array
) -> Array:
	var errors: Array = []

	for field in REQUIRED_TEXT_FIELDS:
		if not node.has(field) or str(node.get(field, "")).strip_edges().is_empty():
			errors.append("nó '%s': campo de texto vazio ou ausente: %s" % [node_id, field])

	var is_end := bool(node.get("end", false))
	var has_next := node.has("next")
	var has_choices := node.has("choices")
	var has_objective := node.has("objective")

	if is_end and (has_next or has_choices):
		errors.append("nó '%s': 'end' não pode ter 'next' nem 'choices'" % node_id)
	if not is_end and not has_next and not has_choices and not has_objective:
		errors.append("nó '%s': sem saída ('end', 'next', 'choices' ou 'objective')" % node_id)

	if has_next:
		var next_id := str(node.get("next", ""))
		if not nodes.has(next_id):
			errors.append("nó '%s': 'next' aponta para nó inexistente: %s" % [node_id, next_id])

	if has_choices:
		var choices = node.get("choices", [])
		if typeof(choices) != TYPE_ARRAY:
			errors.append("nó '%s': 'choices' deve ser uma lista" % node_id)
		elif choices.is_empty():
			errors.append("nó '%s': 'choices' vazio" % node_id)
		elif choices.size() > MAX_CHOICES:
			errors.append("nó '%s': máximo de %d escolhas (tem %d)" % [node_id, MAX_CHOICES, choices.size()])
		else:
			for index in choices.size():
				var choice = choices[index]
				if typeof(choice) != TYPE_DICTIONARY:
					errors.append("nó '%s': escolha %d não é objeto" % [node_id, index])
					continue
				for field in ["en", "pt", "next"]:
					if not choice.has(field) or str(choice.get(field, "")).strip_edges().is_empty():
						errors.append("nó '%s': escolha %d sem '%s'" % [node_id, index, field])
				var choice_next := str(choice.get("next", ""))
				if not nodes.has(choice_next):
					errors.append("nó '%s': escolha %d aponta para nó inexistente: %s" % [node_id, index, choice_next])

	if has_objective:
		var objective = node.get("objective", {})
		if typeof(objective) != TYPE_DICTIONARY:
			errors.append("nó '%s': 'objective' deve ser um objeto" % node_id)
		else:
			var device_id := str(objective.get("device", ""))
			var state := str(objective.get("state", ""))
			if not device_ids.has(device_id):
				errors.append("nó '%s': objective.device desconhecido: %s" % [node_id, device_id])
			if not VALID_STATES.has(state):
				errors.append("nó '%s': objective.state inválido: %s" % [node_id, state])
		if not has_next:
			errors.append("nó '%s': 'objective' precisa de 'next' para continuar" % node_id)

	if node.has("vocab"):
		var vocab = node.get("vocab", [])
		if typeof(vocab) != TYPE_ARRAY:
			errors.append("nó '%s': 'vocab' deve ser uma lista" % node_id)
		else:
			for index in vocab.size():
				var entry = vocab[index]
				if typeof(entry) != TYPE_DICTIONARY or not entry.has("en") or not entry.has("pt"):
					errors.append("nó '%s': vocab[%d] precisa de 'en' e 'pt'" % [node_id, index])

	return errors


static func _collect_reachable(node_id: String, nodes: Dictionary, visited: Dictionary) -> void:
	if visited.has(node_id) or not nodes.has(node_id):
		return
	visited[node_id] = true
	var node: Dictionary = nodes[node_id]
	if node.has("next"):
		_collect_reachable(str(node.get("next", "")), nodes, visited)
	if node.has("choices") and typeof(node["choices"]) == TYPE_ARRAY:
		for choice in node["choices"]:
			if typeof(choice) == TYPE_DICTIONARY:
				_collect_reachable(str(choice.get("next", "")), nodes, visited)
