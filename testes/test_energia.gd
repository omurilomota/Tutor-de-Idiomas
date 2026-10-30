extends RefCounted
## Testes da simulação de energia, do baseline e do relatório.

const DeviceScript = preload("res://scripts/energia/EnergyDevice.gd")
const ReportScript = preload("res://scripts/energia/EnergyReport.gd")
const ManagerScript = preload("res://scripts/autoload/EnergyManager.gd")


func run(t) -> void:
	_testa_dispositivo(t)
	_testa_baseline(t)
	_testa_relatorio(t)
	_testa_balanceamento(t)
	_testa_fim_do_dia(t)
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
		"watt_eco": 550,
		"ligado_inicial": true,
	})
	t.check(ar.current_watts() == 1400.0, "ar ligado consome 1400 W")
	t.check(ar.set_state("eco"), "ar aceita modo eco")
	t.check(ar.current_watts() == 550.0, "ar em eco consome 550 W")
	t.check(ar.next_state() == "off", "ciclo do ar: eco -> off")
	t.check(ar.set_state("off"), "ar aceita desligar")
	t.check(ar.current_watts() == 5.0, "ar desligado fica nos 5 W de standby")
	t.check(ar.next_state() == "on", "ciclo do ar: off -> on")
	t.check(not ar.set_state("turbo"), "estado inválido é rejeitado")


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


func _testa_balanceamento(t) -> void:
	# Cenários do dia inteiro (14 h), medidos com a mesma função do relatório.
	var nenhum := _cenario_pct(t, {})
	t.check(is_equal_approx(nenhum, 0.0), "nada feito = 0%% de economia (%.1f)" % nenhum)

	var luz := _cenario_pct(t, {"lampada_sala": "off"})
	t.check(absf(luz - 3.8) < 0.3, "só apagar a luz ≈ 3,8%% (%.1f)" % luz)

	var luz_tv := _cenario_pct(t, {"lampada_sala": "off", "tv_sala": "off"})
	t.check(absf(luz_tv - 10.3) < 0.3, "luz + TV ≈ 10,3%% (TV fica em standby) (%.1f)" % luz_tv)

	var otimizado := _cenario_pct(t, {
		"lampada_sala": "off",
		"tv_sala": "off",
		"ar_sala": "eco",
		"tomada_carregador": "off",
	})
	t.check(absf(otimizado - 64.6) < 0.6, "todos os objetivos ≈ 64,6%% (%.1f)" % otimizado)

	var manager = ManagerScript.new()
	manager.load_data()
	var base: float = manager.compute_baseline_kwh()
	t.check(absf(base - 22.05) < 0.01, "baseline de 14 h = 22,05 kWh (%.2f)" % base)
	t.check(base >= 20.0, "baseline é alto o bastante para a meta de 20%%")
	var ar_real = manager.get_device("ar_sala")
	t.check(ar_real != null, "dados reais têm o ar-condicionado")
	if ar_real != null:
		t.check(is_equal_approx(ar_real.watt_eco, 550.0), "dados reais do eco = 550 W (não 900)")
	manager.free()


func _cenario_pct(t, states: Dictionary) -> float:
	var manager = ManagerScript.new()
	if not manager.load_data():
		t.check(false, "cenário: EnergyManager carrega dados")
		manager.free()
		return -1.0
	for device_id in states.keys():
		manager.set_device_state(str(device_id), str(states[device_id]))
	manager.simulate_seconds(14.0 * 3600.0)
	var report: Dictionary = ReportScript.build(
		manager.kwh,
		manager.compute_baseline_kwh(),
		manager.config,
		manager.vocabulary,
		manager.actions
	)
	var pct := float(report.get("economia_pct", 0.0))
	manager.free()
	return pct


func _testa_fim_do_dia(t) -> void:
	var manager = ManagerScript.new()
	manager.load_data()
	var reports: Array = []
	manager.day_finished.connect(func(report: Dictionary) -> void: reports.append(report))
	manager.start_day()

	# 420 s reais × escala 120 = 50.400 s de jogo = 14 h (08:00 → 22:00).
	manager._process(420.0)
	t.check(manager.day_ended, "o relógio encerra o dia às 22:00")
	t.check(manager.clock_minutes == int(manager.config.get("fim_minutos", 1320)), "relógio para em 1320 min")
	t.check(not manager.running, "simulação para no fim do dia")
	t.check(reports.size() == 1, "day_finished emite exatamente um relatório")
	if reports.size() == 1:
		var report: Dictionary = reports[0]
		t.check(float(report.get("economia_pct", -1.0)) == 0.0, "quem não faz nada tem 0%% de economia")
		t.check(float(report.get("kwh_jogador", 0.0)) > 20.0, "dia inteiro ligado consome >20 kWh")
	manager.free()


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
