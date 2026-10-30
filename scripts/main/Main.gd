extends Node3D
## Orquestra a partida: inicia o dia, encadeia os diálogos e trata o reinício.
## A cena expõe %SalaEstar, %Player, %HUD, %CaixaDialogo e %TelaRelatorio.

const DIALOGUE_SEQUENCE: Array[String] = [
	"sala_01",
	"sala_02",
	"sala_03",
	"sala_04",
]

@onready var player = %Player
@onready var hud = %HUD
@onready var tela_relatorio = %TelaRelatorio

var _spawn_transform: Transform3D
var _dialogue_index: int = 0
var _restarting: bool = false
var _started: bool = false
var _sequence_timer: Timer = null


func _ready() -> void:
	_spawn_transform = player.transform
	# Timer como nó filho (em vez de SceneTreeTimer): reinício/fim do dia
	# cancelam a transição e o timer morre junto com a cena.
	_sequence_timer = Timer.new()
	_sequence_timer.one_shot = true
	_sequence_timer.wait_time = 0.35
	_sequence_timer.timeout.connect(_on_sequence_timeout)
	add_child(_sequence_timer)
	EnergyManager.day_finished.connect(_on_day_finished)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	tela_relatorio.restart_requested.connect(_on_restart_requested)
	var interactor = player.get_node_or_null("%Interactor")
	if interactor != null and hud.has_method("on_target_changed"):
		interactor.target_changed.connect(hud.on_target_changed)
	call_deferred("start_game")


func _unhandled_input(event: InputEvent) -> void:
	# Atalho de debug para a apresentação: encerra o dia sem esperar 22:00.
	if event.is_action_pressed("debug_finish_day") and not EnergyManager.day_ended:
		EnergyManager.finish_day()
		get_viewport().set_input_as_handled()


func start_game() -> void:
	if _started:
		return
	_started = true
	if _sequence_timer != null:
		_sequence_timer.stop()
	GameState.reset_progress()
	EnergyManager.start_day()
	DialogueManager.reload()
	player.transform = _spawn_transform
	player.reset_view()
	player.set_active(true)
	_dialogue_index = 0
	_next_dialogue()


func _next_dialogue() -> void:
	if _dialogue_index >= DIALOGUE_SEQUENCE.size():
		return
	var dialogue_id := DIALOGUE_SEQUENCE[_dialogue_index]
	_dialogue_index += 1
	if not DialogueManager.start(dialogue_id):
		push_warning("Diálogo '%s' não abriu; seguindo para o próximo." % dialogue_id)
		_next_dialogue()


func _on_dialogue_finished(_dialogue_id: String) -> void:
	if _restarting or EnergyManager.day_ended:
		return
	if _dialogue_index >= DIALOGUE_SEQUENCE.size():
		return
	_sequence_timer.start()


func _on_sequence_timeout() -> void:
	if EnergyManager.day_ended or not _started or _restarting:
		return
	_next_dialogue()


func _on_day_finished(_report: Dictionary) -> void:
	if _sequence_timer != null:
		_sequence_timer.stop()
	if DialogueManager.active:
		DialogueManager.stop()
	player.set_active(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if hud.has_method("set_objetivo"):
		hud.set_objetivo("")
	if hud.has_method("clear_prompt"):
		hud.clear_prompt()


func _on_restart_requested() -> void:
	_restarting = true
	if _sequence_timer != null:
		_sequence_timer.stop()
	if DialogueManager.active:
		DialogueManager.stop()
	GameState.reset_progress()
	EnergyManager.start_day()
	tela_relatorio.hide()
	player.transform = _spawn_transform
	player.reset_view()
	player.set_active(true)
	_dialogue_index = 0
	_restarting = false
	_next_dialogue()
