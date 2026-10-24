extends RefCounted
## Carrega diálogos em JSON. O conteúdo é escrito por quem não programa (Matheus/roteirista).


static func load_dialogue(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Diálogo não encontrado: %s" % path)
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("JSON inválido em %s" % path)
		return {}
	return parsed


static func load_directory(dir_path: String) -> Dictionary:
	var result: Dictionary = {}
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("Pasta de diálogos não encontrada: %s" % dir_path)
		return result

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var full_path := dir_path.path_join(file_name)
			var data := load_dialogue(full_path)
			# Ignora arquivos que não são diálogo (ex.: schema.json).
			if data.has("nodes") and data.has("start"):
				var key := str(data.get("id", file_name.get_basename()))
				result[key] = data
		file_name = dir.get_next()
	dir.list_dir_end()
	return result
