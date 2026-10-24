# 04 — Sistema de energia

A energia é **mecânica em tempo real**, não uma tela de resultado. Cada ação do jogador
altera o consumo no mesmo instante e o relatório final apenas consolida o que aconteceu.

## Fórmula

Para cada dispositivo, a cada tick:

```
E_kWh += P_W × dt_s / 3_600_000
```

- `P_W` é o consumo atual (ligado, standby ou eco).
- `dt_s` é o tempo de jogo decorrido (já multiplicado pela escala de tempo).
- 1 kWh = 3.600.000 J.

O relógio anda com `escala_tempo = 120`: **1 segundo real = 2 minutos de jogo**.
O dia vai de 08:00 a 22:00 (840 min) → **7 minutos reais** por partida.
Durante o diálogo o tempo pausa (`EnergyManager.paused = true`).

## Dispositivos

| id | Ligado | Standby | Eco | Observação |
|---|---|---|---|---|
| `lampada_sala` | 60 W | 0 W | — | sem standby |
| `tv_sala` | 110 W | 8 W | — | desligar não zera o consumo |
| `ar_sala` | 1400 W | 5 W | 900 W | ciclo `on → eco → off` |
| `tomada_carregador` | 5 W | 0 W | — | “off” = fora da tomada |

Regra de interação: dispositivos com `watt_eco > 0` ciclam `on → eco → off`; os demais
alternam `on ↔ off`. O estado vive em `EnergyDevice` e é publicado no barramento simulado.

## Baseline (a conta que a banca vai conferir)

O baseline **não é um número fixo**: é a mesma função de consumo rodando com o perfil
`dados/baseline.json` (tudo ligado, ar a 18 °C por 6 h).

```
baseline_kwh = Σ (watt_on × horas_ligado + watt_standby × (horas_do_dia − horas_ligado)) / 1000
```

Com os dados atuais (`horas_do_dia = 14`):

| Dispositivo | Conta | kWh |
|---|---|---|
| Lâmpada | 60 × 14 / 1000 | 0,84 |
| TV | 110 × 14 / 1000 | 1,54 |
| Ar | (1400 × 6 + 5 × 8) / 1000 | 8,44 |
| Carregador | 5 × 14 / 1000 | 0,07 |
| **Total** | | **10,89** |

Custo baseline: `10,89 × 0,75 = R$ 8,17`.
CO₂ baseline: `10,89 × 0,084 = 0,915 kg`.

## Relatório

```
economia_kwh  = max(baseline_kwh − jogador_kwh, 0)
economia_%    = economia_kwh / baseline_kwh × 100
custo_evitado = economia_kwh × tarifa
co2_evitado   = economia_kwh × fator_co2
nota          = A ≥30% | B ≥20% | C ≥10% | D <10%
```

Exemplo de partida otimizada:

| Dispositivo | Uso do jogador | kWh |
|---|---|---|
| Lâmpada | 2 h ligada | 0,12 |
| TV | 2 h ligada + 12 h standby | 0,316 |
| Ar | 1 h normal + 2 h eco + 11 h standby | 3,255 |
| Carregador | fora da tomada | 0,00 |
| **Total** | | **3,691** |

Economia: `(10,89 − 3,691) / 10,89 = 66,1%` → nota **A**, R$ 5,40 e 0,60 kg CO₂ evitados.

## Parâmetros (`dados/config.json`)

| Campo | Valor | Observação |
|---|---|---|
| `tarifa_brl_kwh` | 0,75 | valor configurável para a demo; citar a fonte no relatório |
| `co2_kg_por_kwh` | 0,084 | ordem de grandeza do SIN; configurável |
| `escala_tempo` | 120 | 1 s real = 2 min de jogo |
| `inicio_minutos` | 480 | 08:00 |
| `fim_minutos` | 1320 | 22:00 |
| `meta_economia_pct` | 20 | meta para “passar” |

**Importante:** os valores de tarifa e CO₂ são parâmetros didáticos, não uma medição.
A banca deve ser informada disso; o doc 09 registra a limitação.

## HUD ao vivo

| Indicador | Fonte | Atualização |
|---|---|---|
| kW agora | soma de `current_watts()` | a cada frame |
| kWh | acumulador | a cada frame |
| R$ | `kwh × tarifa` | a cada frame |
| CO₂ | `kwh × fator` | a cada frame |
| Relógio | `clock_minutes` | a cada minuto simulado |
| Dispositivos | `device_changed` | a cada interação |

## IoT simulado

Cada mudança publica em `EnergyBus`:

```
home/sala/lampada_sala/state
{ "ligado": false, "modo": "off", "watts": 0 }
```

O painel do HUD lê esses estados. É uma **simulação** de barramento MQTT — não há broker
nem rede. Isso cobre o tema “IoT” de forma honesta (ver doc 09).

## Testes

`testes/test_energia.gd` verifica:

- consumo ligado/standby/eco;
- baseline de 14 h = 1,54 kWh para a TV;
- relatório: 20% → nota B, R$ 1,50 e conta fechada;
- simulação de 1 h com os 4 dispositivos reais.

```bash
godot --headless --path . --script testes/run_tests.gd
```

## Balanceamento

| Cenário | Economia esperada |
|---|---|
| Não faz nada | ~0% |
| Só apaga a luz | ~8% |
| Luz + TV | ~22% |
| Luz + TV + ar em eco | ~66% |

Se a meta de 20% estiver fácil demais no playtest, aumentar `watt_on` do ar ou reduzir
`horas_ligado` do baseline. A regra é: **o jogador precisa entender o pedido em inglês
para conseguir economizar.**
