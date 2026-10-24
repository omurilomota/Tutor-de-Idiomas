extends PanelContainer
## Cartão que aparece quando o jogador desbloqueia uma palavra/frase nova.

@onready var texto_en: Label = %TextoEN
@onready var texto_pt: Label = %TextoPT

@export var visible_seconds: float = 3.5


func _ready() -> void:
	DialogueManager.vocabulary_unlocked.connect(_on_vocabulary_unlocked)
	hide()


func _on_vocabulary_unlocked(entry: Dictionary) -> void:
	texto_en.text = str(entry.get("en", ""))
	texto_pt.text = str(entry.get("pt", ""))
	show()
	var tween := create_tween()
	tween.tween_interval(visible_seconds)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(_reset)
	reset_size()
	modulate.a = 1.0


func _reset() -> void:
	hide()
	modulate.a = 1.0
