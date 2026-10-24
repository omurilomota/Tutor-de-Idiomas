extends Node
## Troca de cenas centralizada. Autoload: SceneRouter

signal scene_changed(path: String)

var _busy: bool = false


func go_to(path: String) -> void:
	if _busy:
		return
	if not ResourceLoader.exists(path):
		push_error("Cena não encontrada: %s" % path)
		return
	_busy = true
	var result := get_tree().change_scene_to_file(path)
	if result != OK:
		push_error("Falha ao trocar para a cena %s (erro %d)" % [path, result])
	_busy = false
	if result == OK:
		scene_changed.emit(path)


func reload_current() -> void:
	var scene := get_tree().current_scene
	if scene != null and not scene.scene_file_path.is_empty():
		go_to(scene.scene_file_path)
