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
Durante o diálogo o tempo pausa (`EnergyManager.paused = true`) e volta quando a última
fala fecha. `F4` encerra o dia na hora (atalho de debug/apresentação).

## Dispositivos

| id | Ligado | Standby | Eco | Observação |
|---|---|---|---|---|
| `lampada_sala` | 60 W | 0 W | — | sem standby |
| `tv_sala` | 110 W | 8 W | — | desligar não zera o consumo |
| `ar_sala` | 1400 W | 5 W | **550 W** | ciclo `on → eco → off` |
| `tomada_carregador` | 5 W | 0 W | — | “off” = fora da tomada |

Regra de interação: dispositivos com `watt_eco > 0` ciclam `on → eco → off`; os demais
alternam `on ↔ off`. O estado vive em `EnergyDevice` e é publicado no barramento simulado.
Cada mudança também emite `device_changed`, que o HUD, o `EnergyDevice3D` e o
`DialogueManager` escutam.

## Baseline (a conta que a banca vai conferir)

O baseline **não é um número fixo**: é a mesma função de consumo rodando com o perfil
`dados/baseline.json` (tudo ligado das 08:00 às 22:00, ar em 18 °C o dia inteiro).

```
baseline_kwh = Σ (watt_on × horas_ligado + watt_standby × (horas_do_dia − horas_ligado)) / 1000
```

Com os dados atuais (`horas_do_dia = 14`, `horas_ligado = 14` para todos):

| Dispositivo | Conta | kWh |
|---|---|---|
| Lâmpada | 60 × 14 / 1000 | 0,84 |
| TV | 110 × 14 / 1000 | 1,54 |
| Ar | 1400 × 14 / 1000 | 19,60 |
| Carregador | 5 × 14 / 1000 | 0,07 |
| **Total** | | **22,05** |

Custo baseline: `22,05 × 0,75 = R$ 16,54`.
CO₂ baseline: `22,05 × 0,084 = 1,852 kg`.

> **Mudança registrada:** o baseline antigo deixava o ar ligado só 6 h. Com ar em eco de
> 900 W e o jogador deixando-o ligado o dia inteiro, o consumo ficava **maior** que o
> baseline — ou seja, “obedecer ao pedido de eco” piorava a nota. Agora o baseline é o
> cenário honesto de “não fazer nada” (tudo ligado 14 h) e o eco de 550 W garante que a
> terceira missão realmente economiza. Os números antigos de 8%/22%/65% foram
> substituídos pelos medidos abaixo.

## Relatório

```
economia_kwh  = max(baseline_kwh − jogador_kwh, 0)
economia_%    = economia_kwh / baseline_kwh × 100
custo_evitado = economia_kwh × tarifa
co2_evitado   = economia_kwh × fator_co2
nota          = A ≥30% | B ≥20% | C ≥10% | D <10%
```

Exemplo de partida ótima (luz apagada, TV desligada, ar em eco, carregador fora):

| Dispositivo | Uso do jogador | kWh |
|---|---|---|
| Lâmpada | desligada | 0,00 |
| TV | desligada, em standby 8 W por 14 h | 0,112 |
| Ar | eco 550 W por 14 h | 7,70 |
| Carregador | fora da tomada | 0,00 |
| **Total** | | **7,812** |

Economia: `(22,05 − 7,812) / 22,05 = 64,6%` → nota **A**, R$ 10,68 e 1,196 kg CO₂ evitados.
É exatamente a tela de `docs/img/relatorio.png`.

## Balanceamento medido

| Cenário | Cálculo | Economia |
|---|---|---|
| Não faz nada | 22,05 kWh | 0,0% |
| Só apaga a luz | 22,05 − 0,84 | 3,8% |
| Luz + TV | 22,05 − 0,84 − 1,428 (TV fica em standby) | 10,3% |
| Luz + TV + ar em eco + carregador | 22,05 − 14,238 | **64,6%** |
| Tudo desligado (ar off) | 22,05 − 0,112 | 99,5% |

A meta de 20% exige a terceira missão: só luz + TV dá 10,3% (nota C). Fazer os três
pedidos do Alex garante nota A. Esses valores são verificados por
`testes/test_energia.gd` com tolerância de 0,3–0,6 ponto percentual.

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
| FPS | `Engine.get_frames_per_second()` | `F3`, a cada 0,25 s |

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

- consumo ligado/standby/eco e ciclo do ar (1400 → 550 → off);
- baseline de 14 h = 1,54 kWh para a TV;
- relatório: 20% → nota B, R$ 1,50 e conta fechada;
- cenários do balanceamento (0%, 3,8%, 10,3%, 64,6%);
- fim do dia pelo relógio (420 s reais → 22:00 → um único relatório);
- simulação de 1 h com os 4 dispositivos reais (1,575 kWh).

```bash
godot --headless --path . --script testes/run_tests.gd
```

## Performance

`tools/benchmark_fps.gd` roda a partida real a 1280×720. Resultado no renderizador
**por software** llvmpipe: **≈90–100 FPS** em 300 frames, muito acima do gate de 30 FPS.
O jogo usa sombras/AA desligados, sem pós-processamento e com poucos triângulos.
