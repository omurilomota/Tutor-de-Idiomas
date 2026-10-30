extends PanelContainer
## Cartão que aparece quando o jogador desbloqueia uma palavra/frase nova.
## Se várias palavras chegam juntas, cada uma aparece em sequência.

@onready var texto_en: Label = %TextoEN
@onready var texto_pt: Label = %TextoPT

@export var visible_seconds: float = 3.0

var _queue: Array = []
var _showing: bool = false


func _ready() -> void:
	DialogueManager.vocabulary_unlocked.connect(_on_vocabulary_unlocked)
	hide()


func _on_vocabulary_unlocked(entry: Dictionary) -> void:
	_queue.append(entry.duplicate(true))
	if not _showing:
		_show_next()


func _show_next() -> void:
	if _queue.is_empty():
		_showing = false
		hide()
		return

	_showing = true
	var entry: Dictionary = _queue.pop_front()
	texto_en.text = str(entry.get("en", ""))
	texto_pt.text = str(entry.get("pt", ""))
	modulate.a = 1.0
	show()

	var tween := create_tween()
	tween.tween_interval(visible_seconds)
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	tween.tween_callback(_on_card_hidden)


func _on_card_hidden() -> void:
	modulate.a = 1.0
	_show_next()
