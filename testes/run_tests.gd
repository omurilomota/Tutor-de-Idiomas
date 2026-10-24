extends SceneTree
## Runner de testes sem dependências externas.
## Uso: godot --headless --path . --script testes/run_tests.gd

const TestDialogos = preload("res://testes/test_dialogos.gd")
const TestEnergia = preload("res://testes/test_energia.gd")

var failures: Array = []
var checks: int = 0


func _initialize() -> void:
	print("== Home Switch — testes ==")
	_run(TestDialogos)
	_run(TestEnergia)
	print("Verificações: %d | Falhas: %d" % [checks, failures.size()])
	if failures.is_empty():
		print("OK")
		quit(0)
	else:
		for failure in failures:
			printerr("FALHOU: %s" % failure)
		quit(1)


func _run(test_script) -> void:
	var instance = test_script.new()
	if instance.has_method("run"):
		instance.run(self)


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
