extends RefCounted
## Cálculo do baseline de desperdício e montagem do relatório final.
## O baseline roda o MESMO modelo de consumo com um perfil fixo — não é número mágico.

static func baseline_kwh(devices: Dictionary, profile: Dictionary, day_hours: float) -> float:
	var hours: Dictionary = profile.get("horas_ligado", {})
	var total := 0.0
	for device_id in devices.keys():
		var device = devices[device_id]
		var on_hours := clampf(float(hours.get(device_id, 0.0)), 0.0, day_hours)
		var off_hours := maxf(day_hours - on_hours, 0.0)
		total += (device.watt_on * on_hours + device.watt_standby * off_hours) / 1000.0
	return total


static func build(
	player_kwh: float,
	base_kwh: float,
	config: Dictionary,
	vocabulary: Array,
	actions: Array
) -> Dictionary:
	var saved := maxf(base_kwh - player_kwh, 0.0)
	var savings_pct := 0.0
	if base_kwh > 0.0:
		savings_pct = saved / base_kwh * 100.0

	var tariff := float(config.get("tarifa_brl_kwh", 0.75))
	var co2_factor := float(config.get("co2_kg_por_kwh", 0.084))

	return {
		"kwh_jogador": snappedf(player_kwh, 0.001),
		"kwh_baseline": snappedf(base_kwh, 0.001),
		"economia_kwh": snappedf(saved, 0.001),
		"economia_pct": snappedf(savings_pct, 0.1),
		"custo_evitado_brl": snappedf(saved * tariff, 0.01),
		"co2_evitado_kg": snappedf(saved * co2_factor, 0.001),
		"tarifa_brl_kwh": tariff,
		"co2_kg_por_kwh": co2_factor,
		"meta_pct": float(config.get("meta_economia_pct", 20.0)),
		"vocabulario": vocabulary.duplicate(true),
		"acoes": actions.duplicate(true),
		"nota": grade(savings_pct),
	}


static func grade(savings_pct: float) -> String:
	if savings_pct >= 30.0:
		return "A"
	if savings_pct >= 20.0:
		return "B"
	if savings_pct >= 10.0:
		return "C"
	return "D"
