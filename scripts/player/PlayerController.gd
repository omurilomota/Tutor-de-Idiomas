extends CharacterBody3D
## Controlador em primeira pessoa (WASD + mouse). Usado a partir da Fase 1.

@export var speed: float = 3.5
@export var mouse_sensitivity: float = 0.0025
@export var camera_limit_degrees: float = 80.0

@onready var camera: Camera3D = get_node_or_null("%Camera3D")

var _gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		if camera != null:
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			var limit := deg_to_rad(camera_limit_degrees)
			camera.rotation.x = clampf(camera.rotation.x, -limit, limit)

	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()
