extends Node
## Simulação de energia em tempo real. Autoload: EnergyManager
## O relógio do dia acelera o tempo e cada dispositivo consome conforme o estado.

signal device_changed(device_id: String, is_on: bool, watts: float)
signal energy_updated(kwh: float, cost_brl: float, co2_kg: float, kw_now: float)
signal clock_updated(clock_minutes: int)
signal day_finished(report: Dictionary)
signal vocabulary_unlocked(entry: Dictionary)

const EnergyDeviceScript = preload("res://scripts/energia/EnergyDevice.gd")
const EnergyBusScript = preload("res://scripts/energia/EnergyBus.gd")
const EnergyReportScript = preload("res://scripts/energia/EnergyReport.gd")

const DEVICES_PATH := "res://dados/dispositivos.json"
const CONFIG_PATH := "res://dados/config.json"
const BASELINE_PATH := "res://dados/baseline.json"

var devices: Dictionary = {}
var config: Dictionary = {}
var baseline_profile: Dictionary = {}
var bus = null

var clock_minutes: int = 480
var clock_seconds: float = 0.0
var kwh: float = 0.0
var running: bool = false
var paused: bool = false
var day_ended: bool = false

var actions: Array = []
var vocabulary: Array = []

var _last_emitted_minute: int = -1


func _ready() -> void:
	load_data()
	set_process(false)


func load_data() -> bool:
	if bus == null:
		bus = EnergyBusScript.new()

	var cfg = _read_json(CONFIG_PATH)
	var devs = _read_json(DEVICES_PATH)
	var base = _read_json(BASELINE_PATH)
	if cfg.is_empty() or devs.is_empty() or base.is_empty():
		push_error("EnergyManager: não foi possível carregar os dados em res://dados/")
		return false

	config = cfg
	baseline_profile = base
	devices.clear()
	for entry in devs.get("dispositivos", []):
		var device = EnergyDeviceScript.new(entry)
		devices[device.id] = device

	clock_minutes = int(config.get("inicio_minutos", 480))
	clock_seconds = 0.0
	kwh = 0.0
	return true


func start_day() -> void:
	load_data()
	running = true
	paused = false
	day_ended = false
	clock_seconds = 0.0
	clock_minutes = int(config.get("inicio_minutos", 480))
	_last_emitted_minute = -1
	kwh = 0.0
	actions.clear()
	vocabulary.clear()
	set_process(true)
	_emit_energy()
	clock_updated.emit(clock_minutes)


func set_paused(value: bool) -> void:
	paused = value


func _process(delta: float) -> void:
	if not running or paused or day_ended:
		return

	var time_scale := float(config.get("escala_tempo", 120.0))
	var game_seconds := delta * time_scale
	simulate_seconds(game_seconds)

	clock_seconds += game_seconds
	clock_minutes = int(config.get("inicio_minutos", 480)) + int(clock_seconds / 60.0)
	if clock_minutes != _last_emitted_minute:
		_last_emitted_minute = clock_minutes
		clock_updated.emit(clock_minutes)

	var end_minutes := int(config.get("fim_minutos", 1320))
	if clock_minutes >= end_minutes:
		finish_day()


func simulate_seconds(game_seconds: float) -> void:
	for device in devices.values():
		var watts: float = device.current_watts()
		kwh += watts * game_seconds / 3_600_000.0
	_emit_energy()


func set_device_state(device_id: String, state: String) -> bool:
	if not devices.has(device_id):
		push_warning("Dispositivo desconhecido: %s" % device_id)
		return false

	var device = devices[device_id]
	if not device.set_state(state):
		push_warning("Estado inválido '%s' para %s" % [state, device_id])
		return false

	var watts: float = device.current_watts()
	device_changed.emit(device_id, device.is_on, watts)
	if bus != null:
		bus.publish(bus.topic_for(device.comodo, device_id), device.to_dict())
	actions.append({
		"device": device_id,
		"state": state,
		"clock": format_clock(clock_minutes),
	})
	_emit_energy()
	return true


func interact(device_id: String) -> bool:
	if not devices.has(device_id):
		return false
	var device = devices[device_id]
	return set_device_state(device_id, device.next_state())


func get_device(device_id: String):
	return devices.get(device_id)


func get_kw_now() -> float:
	var total_watts := 0.0
	for device in devices.values():
		total_watts += device.current_watts()
	return total_watts / 1000.0


func unlock_vocabulary(entry: Dictionary) -> void:
	var key := str(entry.get("en", ""))
	if key.is_empty():
		return
	for existing in vocabulary:
		if str(existing.get("en", "")) == key:
			return
	vocabulary.append(entry.duplicate(true))
	vocabulary_unlocked.emit(entry)


func compute_baseline_kwh() -> float:
	var start_minutes := float(config.get("inicio_minutos", 480))
	var end_minutes := float(config.get("fim_minutos", 1320))
	var day_hours := maxf((end_minutes - start_minutes) / 60.0, 1.0)
	return EnergyReportScript.baseline_kwh(devices, baseline_profile, day_hours)


func finish_day() -> void:
	if day_ended:
		return
	day_ended = true
	running = false
	set_process(false)
	var report: Dictionary = EnergyReportScript.build(
		kwh,
		compute_baseline_kwh(),
		config,
		vocabulary,
		actions
	)
	report["relogio_final"] = format_clock(clock_minutes)
	day_finished.emit(report)


func format_clock(minutes: int) -> String:
	var hours := int(minutes / 60.0) % 24
	var mins := minutes % 60
	return "%02d:%02d" % [hours, mins]


func _emit_energy() -> void:
	var tariff := float(config.get("tarifa_brl_kwh", 0.75))
	var co2_factor := float(config.get("co2_kg_por_kwh", 0.084))
	energy_updated.emit(kwh, kwh * tariff, kwh * co2_factor, get_kw_now())


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Arquivo não encontrado: %s" % path)
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("JSON inválido em %s" % path)
		return {}
	return parsed
