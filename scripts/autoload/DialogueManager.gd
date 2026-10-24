extends Node
## Máquina de estados do diálogo. Autoload: DialogueManager
## Um nó com "objective" só avança quando o jogador executa a ação física correspondente.

signal dialogue_started(dialogue_id: String)
signal line_shown(node: Dictionary)
signal choices_shown(choices: Array)
signal objective_requested(device_id: String, state: String)
signal objective_completed(device_id: String)
signal vocabulary_unlocked(entry: Dictionary)
signal dialogue_finished(dialogue_id: String)

const DialogueLoaderScript = preload("res://scripts/dialogos/DialogueLoader.gd")
const DialogueValidatorScript = preload("res://scripts/dialogos/DialogueValidator.gd")

const DIALOGUES_DIR := "res://dialogos"

var dialogues: Dictionary = {}
var current_id: String = ""
var current: Dictionary = {}
var current_node_id: String = ""
var current_node: Dictionary = {}
var active: bool = false
var waiting_objective: bool = false

var _objective: Dictionary = {}


func _ready() -> void:
	if EnergyManager != null:
		EnergyManager.device_changed.connect(_on_device_changed)
	reload()


func reload() -> void:
	dialogues = DialogueLoaderScript.load_directory(DIALOGUES_DIR)


func list_ids() -> Array:
	return dialogues.keys()


func start(dialogue_id: String) -> bool:
	if not dialogues.has(dialogue_id):
		push_error("Diálogo não encontrado: %s" % dialogue_id)
		return false

	var data: Dictionary = dialogues[dialogue_id]
	var errors := DialogueValidatorScript.validate(data, _device_ids())
	if not errors.is_empty():
		for error in errors:
			push_error("Diálogo '%s': %s" % [dialogue_id, error])
		return false

	current_id = dialogue_id
	current = data
	current_node_id = ""
	current_node = {}
	active = true
	waiting_objective = false
	_objective = {}
	EnergyManager.set_paused(true)
	dialogue_started.emit(dialogue_id)
	_go_to(str(data.get("start", "")))
	return true


func advance() -> void:
	if not active or waiting_objective:
		return
	if bool(current_node.get("end", false)):
		_finish()
		return
	if current_node.has("next"):
		_go_to(str(current_node.get("next", "")))


func choose(index: int) -> void:
	if not active or waiting_objective:
		return
	var choices: Array = current_node.get("choices", [])
	if index < 0 or index >= choices.size():
		return
	var next_id := str(choices[index].get("next", ""))
	_go_to(next_id)


func stop() -> void:
	if not active:
		return
	_finish()


func _go_to(node_id: String) -> void:
	var nodes: Dictionary = current.get("nodes", {})
	if not nodes.has(node_id):
		push_error("Nó inexistente '%s' no diálogo '%s'" % [node_id, current_id])
		_finish()
		return

	current_node_id = node_id
	current_node = nodes[node_id]

	if current_node.has("vocab"):
		for entry in current_node.get("vocab", []):
			if typeof(entry) == TYPE_DICTIONARY:
				EnergyManager.unlock_vocabulary(entry)
				GameState.register_vocabulary(entry)
				vocabulary_unlocked.emit(entry)

	if current_node.has("objective"):
		_objective = current_node.get("objective", {})
		waiting_objective = true
		line_shown.emit(current_node)
		objective_requested.emit(
			str(_objective.get("device", "")),
			str(_objective.get("state", ""))
		)
		return

	line_shown.emit(current_node)

	if bool(current_node.get("end", false)):
		return

	if current_node.has("choices"):
		var choices: Array = current_node.get("choices", [])
		choices_shown.emit(choices)
	elif current_node.has("next"):
		# Avança quando a caixa de diálogo chamar advance() (tecla E / clique).
		pass


func _on_device_changed(device_id: String, is_on: bool, _watts: float) -> void:
	if not active or not waiting_objective:
		return
	if str(_objective.get("device", "")) != device_id:
		return

	var target := str(_objective.get("state", ""))
	var matches := false
	match target:
		"off":
			matches = not is_on
		"on":
			matches = is_on
		"eco":
			var device = EnergyManager.get_device(device_id)
			matches = device != null and device.state_name() == "eco"
	if not matches:
		return

	waiting_objective = false
	_objective = {}
	objective_completed.emit(device_id)
	var next_id := str(current_node.get("next", ""))
	if next_id.is_empty():
		_finish()
	else:
		_go_to(next_id)


func _finish() -> void:
	active = false
	waiting_objective = false
	_objective = {}
	if EnergyManager != null:
		EnergyManager.set_paused(false)
	var finished_id := current_id
	current_id = ""
	current = {}
	current_node_id = ""
	current_node = {}
	dialogue_finished.emit(finished_id)


func _device_ids() -> Array:
	if EnergyManager == null:
		return []
	return EnergyManager.devices.keys()
