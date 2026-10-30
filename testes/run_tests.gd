extends SceneTree
## Runner de testes sem dependências externas.
## Uso: godot --headless --path . --script testes/run_tests.gd

const TestDialogos = preload("res://testes/test_dialogos.gd")
const TestEnergia = preload("res://testes/test_energia.gd")
const TestFluxo = preload("res://testes/test_fluxo.gd")
const TestCenas = preload("res://testes/test_cenas.gd")
const TestPartida = preload("res://testes/test_partida.gd")
const TestUI = preload("res://testes/test_ui.gd")
const TestInput = preload("res://testes/test_input.gd")

var failures: Array = []
var checks: int = 0
var _executed: bool = false


func _initialize() -> void:
	# Os testes rodam no primeiro frame: antes disso os autoloads ainda não
	# executaram _ready() e as conexões de sinal não existem.
	pass


func _process(_delta: float) -> bool:
	if _executed:
		return false
	_executed = true
	_execute()
	return false


func _execute() -> void:
	print("== Home Switch — testes ==")
	print("-- diálogos/conteúdo")
	_run(TestDialogos)
	print("-- energia/baseline")
	_run(TestEnergia)
	print("-- fluxo objetivo → ação → avanço")
	_run(TestFluxo)
	print("-- smoke das cenas")
	_run(TestCenas)
	print("-- partida completa (HUD, relatório, reinício)")
	_run(TestPartida)
	print("-- UI do diálogo (teclado, clique e F1)")
	await _run_ui()
	print("-- entrada, raycast e atalhos")
	await _run_input()
	_print_result()


func _run_ui() -> void:
	var instance = TestUI.new()
	if instance.has_method("run"):
		await instance.run(self)


func _run_input() -> void:
	var instance = TestInput.new()
	if instance.has_method("run"):
		await instance.run(self)


func _print_result() -> void:
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
