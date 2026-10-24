extends Control
## Caixa de diálogo com efeito de máquina de escrever e escolhas numeradas.
## A cena (Gian) deve expor os nós únicos: %Painel, %TextoEN, %TextoPT,
## %ListaEscolhas e %DicaContinuar.

signal advance_requested
signal choice_selected(index: int)

@onready var painel: Control = %Painel
@onready var texto_en: Label = %TextoEN
@onready var texto_pt: Label = %TextoPT
@onready var lista_escolhas: VBoxContainer = %ListaEscolhas
@onready var dica: Label = %DicaContinuar

var _typing: Tween = null
var _has_choices: bool = false
var _active: bool = false


func _ready() -> void:
	DialogueManager.line_shown.connect(_on_line_shown)
	DialogueManager.choices_shown.connect(_on_choices_shown)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	GameState.subtitle_mode_changed.connect(_apply_subtitle_mode)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return

	if _typing != null and _typing.is_running() and event.is_action_pressed("interact"):
		_finish_typing()
		return

	if _has_choices:
		if event is InputEventKey and event.pressed and not event.echo:
			var index: int = event.keycode - KEY_1
			if index >= 0 and index < lista_escolhas.get_child_count():
				choice_selected.emit(index)
		return

	if event.is_action_pressed("interact"):
		advance_requested.emit()


func _on_line_shown(node: Dictionary) -> void:
	show()
	_active = true
	_has_choices = false
	_clear_choices()
	painel.show()

	texto_en.text = str(node.get("en", ""))
	texto_pt.text = str(node.get("pt", ""))
	_apply_subtitle_mode()
	_start_typing()
	dica.text = "E — continuar"


func _on_choices_shown(choices: Array) -> void:
	_has_choices = true
	dica.text = "1–%d — escolher" % choices.size()
	for index in choices.size():
		var choice: Dictionary = choices[index]
		var button := Button.new()
		button.text = "%d. %s\n    %s" % [index + 1, choice.get("en", ""), choice.get("pt", "")]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(func() -> void: choice_selected.emit(index))
		lista_escolhas.add_child(button)


func _on_dialogue_finished(_dialogue_id: String) -> void:
	_active = false
	_has_choices = false
	_clear_choices()
	hide()


func _start_typing() -> void:
	if _typing != null:
		_typing.kill()
	texto_en.visible_ratio = 0.0
	texto_pt.visible_ratio = 0.0
	_typing = create_tween()
	_typing.set_parallel(true)
	_typing.tween_property(texto_en, "visible_ratio", 1.0, 0.9)
	_typing.tween_property(texto_pt, "visible_ratio", 1.0, 0.9)


func _finish_typing() -> void:
	if _typing != null:
		_typing.kill()
	texto_en.visible_ratio = 1.0
	texto_pt.visible_ratio = 1.0


func _apply_subtitle_mode() -> void:
	match GameState.subtitle_mode:
		"en":
			texto_en.show()
			texto_pt.hide()
		"pt":
			texto_en.hide()
			texto_pt.show()
		_:
			texto_en.show()
			texto_pt.show()


func _clear_choices() -> void:
	for child in lista_escolhas.get_children():
		child.queue_free()
