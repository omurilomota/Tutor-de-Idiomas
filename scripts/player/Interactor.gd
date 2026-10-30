extends RayCast3D
## Detecta o dispositivo à frente do jogador e emite o prompt bilíngue.
## A câmera aponta para -Z; o alcance é de 2,5 m (ver docs/01-GDD.md).

signal target_changed(target: Node, prompt_en: String, prompt_pt: String)
signal interacted(target: Node)

@export var max_distance: float = 2.5

var current_target: Node = null

var _last_en: String = ""
var _last_pt: String = ""


func _ready() -> void:
	collision_mask = 2
	collide_with_areas = false
	target_position = Vector3(0.0, 0.0, -max_distance)
	enabled = true


func _physics_process(_delta: float) -> void:
	force_raycast_update()
	var target := get_collider() as Node
	if target != null and not target.has_method("get_prompt_en"):
		target = null

	current_target = target
	var prompt_en: String = ""
	var prompt_pt: String = ""
	if current_target != null:
		prompt_en = str(current_target.get_prompt_en())
		prompt_pt = str(current_target.get_prompt_pt())

	if prompt_en == _last_en and prompt_pt == _last_pt:
		return

	_last_en = prompt_en
	_last_pt = prompt_pt
	target_changed.emit(current_target, prompt_en, prompt_pt)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if EnergyManager.day_ended:
		return
	if DialogueManager.active and not DialogueManager.waiting_objective:
		return
	if current_target == null or not current_target.has_method("interact"):
		return

	current_target.interact()
	interacted.emit(current_target)
	get_viewport().set_input_as_handled()
