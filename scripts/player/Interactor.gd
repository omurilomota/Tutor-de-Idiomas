extends RayCast3D
## Detecta o dispositivo à frente do jogador e emite o prompt bilíngue.

signal target_changed(target: Node, prompt_en: String, prompt_pt: String)
signal interacted(target: Node)

@export var max_distance: float = 2.5

var current_target: Node = null


func _ready() -> void:
	target_position = Vector3(0.0, 0.0, -max_distance)
	enabled = true


func _physics_process(_delta: float) -> void:
	force_raycast_update()
	var collider := get_collider() as Node
	if collider == current_target:
		return

	current_target = collider
	if current_target != null and current_target.has_method("get_prompt_en"):
		target_changed.emit(
			current_target,
			str(current_target.get_prompt_en()),
			str(current_target.get_prompt_pt())
		)
	else:
		target_changed.emit(null, "", "")


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if current_target == null:
		return
	if current_target.has_method("interact"):
		current_target.interact()
		interacted.emit(current_target)
