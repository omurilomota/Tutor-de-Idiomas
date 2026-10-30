extends Control
## Caixa de diálogo com efeito de máquina de escrever e escolhas numeradas.
## A cena expõe %Painel, %Fala, %TextoEN, %TextoPT, %ListaEscolhas e %DicaContinuar.
##
## Fluxo: E completa a digitação; o segundo E avança. Enquanto um objetivo físico
## está pendente, o E é do Interactor (a caixa não consome a tecla).

signal advance_requested
signal choice_selected(index: int)

@onready var painel: Control = %Painel
@onready var texto_en: Label = %TextoEN
@onready var texto_pt: Label = %TextoPT
@onready var lista_escolhas: VBoxContainer = %ListaEscolhas
@onready var dica: Label = %DicaContinuar
@onready var fala: Label = get_node_or_null("%Fala")

var _typing: Tween = null
var _typing_active: bool = false
var _has_choices: bool = false
var _active: bool = false
var _pending_choices: Array = []


func _ready() -> void:
	DialogueManager.line_shown.connect(_on_line_shown)
	DialogueManager.choices_shown.connect(_on_choices_shown)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	DialogueManager.objective_requested.connect(_on_objective_requested)
	DialogueManager.objective_completed.connect(_on_objective_completed)
	GameState.subtitle_mode_changed.connect(_on_subtitle_mode_changed)
	advance_requested.connect(_on_advance_requested)
	choice_selected.connect(_on_choice_selected)
	hide()


func _on_advance_requested() -> void:
	DialogueManager.advance()


func _on_choice_selected(index: int) -> void:
	DialogueManager.choose(index)


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return

	if _typing_active:
		if event.is_action_pressed("interact"):
			_finish_typing()
			get_viewport().set_input_as_handled()
		return

	if DialogueManager.waiting_objective:
		return

	if _has_choices:
		if event is InputEventKey and event.pressed and not event.echo:
			var index: int = event.keycode - KEY_1
			if index >= 0 and index < lista_escolhas.get_child_count():
				choice_selected.emit(index)
				get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("interact"):
		advance_requested.emit()
		get_viewport().set_input_as_handled()


func _on_line_shown(node: Dictionary) -> void:
	show()
	_active = true
	_has_choices = false
	_pending_choices = []
	_clear_choices()
	painel.show()

	if fala != null:
		fala.text = str(node.get("speaker", "Alex"))
	texto_en.text = str(node.get("en", ""))
	texto_pt.text = str(node.get("pt", ""))
	_apply_subtitle_mode()
	_start_typing()

	if node.has("objective"):
		dica.text = "Objetivo: vá até o aparelho e aperte E"
	elif bool(node.get("end", false)):
		dica.text = "E — encerrar"
	elif node.has("choices"):
		dica.text = "Aguarde..."
	else:
		dica.text = "E — continuar"


func _on_choices_shown(choices: Array) -> void:
	_pending_choices = choices.duplicate(true)
	if not _typing_active:
		_build_choices()


func _on_dialogue_finished(_dialogue_id: String) -> void:
	_active = false
	_has_choices = false
	_pending_choices = []
	_clear_choices()
	_finish_typing()
	hide()


func _on_objective_requested(_device_id: String, _state: String) -> void:
	dica.text = "Objetivo: vá até o aparelho e aperte E"


func _on_objective_completed(_device_id: String) -> void:
	dica.text = "E — continuar"


func _on_subtitle_mode_changed(_mode: String) -> void:
	_apply_subtitle_mode()


func _start_typing() -> void:
	_stop_tween()
	texto_en.visible_ratio = 0.0
	texto_pt.visible_ratio = 0.0
	_typing_active = true
	_typing = create_tween()
	_typing.set_parallel(true)
	_typing.tween_property(texto_en, "visible_ratio", 1.0, 0.8)
	_typing.tween_property(texto_pt, "visible_ratio", 1.0, 0.8)
	_typing.chain().tween_callback(_on_typing_finished)


func _on_typing_finished() -> void:
	_typing_active = false
	_typing = null
	texto_en.visible_ratio = 1.0
	texto_pt.visible_ratio = 1.0
	if not _pending_choices.is_empty():
		_build_choices()


func _finish_typing() -> void:
	_stop_tween()
	_typing_active = false
	texto_en.visible_ratio = 1.0
	texto_pt.visible_ratio = 1.0
	if not _pending_choices.is_empty() and lista_escolhas.get_child_count() == 0:
		_build_choices()


func _stop_tween() -> void:
	if _typing != null and _typing.is_valid():
		_typing.kill()
	_typing = null


func _build_choices() -> void:
	_clear_choices()
	_has_choices = true
	dica.text = "1–%d — escolher" % _pending_choices.size()
	for index in _pending_choices.size():
		var choice: Dictionary = _pending_choices[index]
		var button := Button.new()
		button.text = "%d. %s\n    %s" % [
			index + 1,
			str(choice.get("en", "")),
			str(choice.get("pt", "")),
		]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.focus_mode = Control.FOCUS_ALL
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(func() -> void: choice_selected.emit(index))
		lista_escolhas.add_child(button)
	lista_escolhas.show()


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
	_has_choices = false
	for child in lista_escolhas.get_children():
		lista_escolhas.remove_child(child)
		child.queue_free()
