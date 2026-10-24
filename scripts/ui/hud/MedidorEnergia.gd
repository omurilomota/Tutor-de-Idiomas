extends VBoxContainer
## Medidor compacto de consumo instantâneo, comparado com uma referência visual.

@onready var barra: ProgressBar = %Barra
@onready var rotulo: Label = %Rotulo

@export var escala_max_kw: float = 2.0


func _ready() -> void:
	EnergyManager.energy_updated.connect(_on_energy_updated)
	barra.max_value = escala_max_kw
	barra.step = 0.01


func _on_energy_updated(_kwh: float, _cost: float, _co2: float, kw_now: float) -> void:
	barra.value = minf(kw_now, escala_max_kw)
	rotulo.text = "%.2f kW" % kw_now
	var ratio := kw_now / escala_max_kw
	if ratio < 0.33:
		barra.modulate = Color(0.18, 0.76, 0.49)
	elif ratio < 0.66:
		barra.modulate = Color(0.95, 0.75, 0.2)
	else:
		barra.modulate = Color(0.9, 0.3, 0.25)
