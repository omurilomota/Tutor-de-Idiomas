extends RefCounted
## Testes da simulação de energia, do baseline e do relatório.

const DeviceScript = preload("res://scripts/energia/EnergyDevice.gd")
const ReportScript = preload("res://scripts/energia/EnergyReport.gd")
const ManagerScript = preload("res://scripts/autoload/EnergyManager.gd")


func run(t) -> void:
	_testa_dispositivo(t)
	_testa_baseline(t)
	_testa_relatorio(t)
	_testa_simulacao(t)


func _testa_dispositivo(t) -> void:
	var lamp := DeviceScript.new({
		"id": "lampada_sala",
		"watt_on": 60,
		"watt_standby": 0,
		"ligado_inicial": false,
	})
	t.check(lamp.current_watts() == 0.0, "lâmpada desligada consome 0 W")
	lamp.set_state("on")
	t.check(lamp.current_watts() == 60.0, "lâmpada ligada consome 60 W")
	t.check(lamp.next_state() == "off", "lâmpada alterna para desligada")

	var ar := DeviceScript.new({
		"id": "ar_sala",
		"watt_on": 1400,
		"watt_standby": 5,
		"watt_eco": 900,
		"ligado_inicial": true,
	})
	t.check(ar.current_watts() == 1400.0, "ar ligado consome 1400 W")
	t.check(ar.set_state("eco"), "ar aceita modo eco")
	t.check(ar.current_watts() == 900.0, "ar em eco consome 900 W")
	t.check(ar.next_state() == "off", "ciclo do ar: eco -> off")


func _testa_baseline(t) -> void:
	var tv := DeviceScript.new({"id": "tv_sala", "watt_on": 110, "watt_standby": 8})
	var devices := {"tv_sala": tv}
	var profile := {"horas_ligado": {"tv_sala": 14}}
	var base: float = ReportScript.baseline_kwh(devices, profile, 14.0)
	t.check(is_equal_approx(base, 1.54), "baseline da TV por 14 h = 1,54 kWh (obtido %.4f)" % base)


func _testa_relatorio(t) -> void:
	var report: Dictionary = ReportScript.build(
		8.0,
		10.0,
		{"tarifa_brl_kwh": 0.75, "co2_kg_por_kwh": 0.084, "meta_economia_pct": 20.0},
		[{"en": "turn off the TV", "pt": "desligar a TV"}],
		[{"device": "tv_sala", "state": "off"}]
	)
	t.check(is_equal_approx(float(report["economia_kwh"]), 2.0), "economia em kWh = 2,0")
	t.check(is_equal_approx(float(report["economia_pct"]), 20.0), "economia em % = 20,0")
	t.check(is_equal_approx(float(report["custo_evitado_brl"]), 1.5), "custo evitado = R$ 1,50")
	t.check(str(report["nota"]) == "B", "nota B para 20% de economia")


func _testa_simulacao(t) -> void:
	var manager = ManagerScript.new()
	t.check(manager.load_data(), "EnergyManager carrega dados reais")
	if manager.devices.is_empty():
		manager.free()
		return

	var expected_watts := 0.0
	for device in manager.devices.values():
		expected_watts += device.current_watts()
	manager.kwh = 0.0
	manager.simulate_seconds(3600.0)
	var expected_kwh: float = expected_watts / 1000.0
	t.check(
		is_equal_approx(manager.kwh, expected_kwh),
		"1 h de simulação fecha a conta (%.4f kWh)" % manager.kwh
	)

	t.check(manager.set_device_state("tv_sala", "off"), "desliga a TV")
	t.check(manager.get_kw_now() < expected_watts / 1000.0, "consumo cai ao desligar a TV")
	t.check(manager.compute_baseline_kwh() > manager.kwh, "baseline é maior que o consumo otimizado")

	manager.free()
