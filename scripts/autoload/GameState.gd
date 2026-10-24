extends Node
## Estado global da partida, preferências de idioma e progresso do jogador.
## Autoload: GameState

signal language_changed(language: String)
signal subtitle_mode_changed(mode: String)
signal paused_changed(is_paused: bool)
signal vocabulary_registered(entry: Dictionary)

const SUBTITLE_MODES: Array[String] = ["both", "en", "pt"]

var language: String = "en"
var native_language: String = "pt_BR"
var subtitle_mode: String = "both"
var is_paused: bool = false

var vocabulary: Array = []
var actions_log: Array = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func set_subtitle_mode(mode: String) -> void:
	if not SUBTITLE_MODES.has(mode):
		push_warning("Modo de legenda inválido: %s" % mode)
		return
	subtitle_mode = mode
	subtitle_mode_changed.emit(mode)


func cycle_subtitle_mode() -> void:
	var index := SUBTITLE_MODES.find(subtitle_mode)
	set_subtitle_mode(SUBTITLE_MODES[(index + 1) % SUBTITLE_MODES.size()])


func set_language(code: String) -> void:
	language = code
	language_changed.emit(code)


func set_paused(value: bool) -> void:
	is_paused = value
	get_tree().paused = value
	paused_changed.emit(value)


func register_vocabulary(entry: Dictionary) -> void:
	var key := str(entry.get("en", ""))
	if key.is_empty():
		return
	for existing in vocabulary:
		if str(existing.get("en", "")) == key:
			return
	vocabulary.append(entry.duplicate(true))
	vocabulary_registered.emit(entry)


func reset_progress() -> void:
	vocabulary.clear()
	actions_log.clear()
