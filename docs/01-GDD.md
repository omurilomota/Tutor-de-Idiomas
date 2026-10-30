# 01 — Game Design Document (GDD)

## Fantasia

O jogador acabou de se mudar para um apartamento dividido com Alex, um colega
falante de inglês. A casa está ligada toda ao mesmo tempo. Alex pede ajuda em inglês;
cada pedido é uma oportunidade de aprender vocabulário e economizar energia.

## Loop de jogo

```
Alex fala (EN + legenda PT)
        ↓
jogador escolhe uma resposta (2–4 opções)
        ↓
Alex pede uma ação física ("turn off the TV")
        ↓
jogador anda até o objeto e aperta E
        ↓
medidor reage (kW ↓, kWh ↓, R$ ↓, CO₂ ↓)
        ↓
cartão de vocabulário + próximo pedido
        ↓
fim do dia → relatório (economia vs. baseline, nota, glossário)
```

Duração alvo: **5–8 minutos** por partida.

## Espaço — sala de estar

Planta simples, ~6 × 5 m, sem portas (MVP):

```
┌──────────────────────────────────────────┐
│  TV + rack            ar-condicionado    │
│  [TV]                  [AC]              │
│                                          │
│        sofá              lâmpada         │
│       [   ]               [💡]           │
│                                          │
│  tapete          carregador   planta     │
│                  [🔌]                    │
│              spawn do jogador            │
└──────────────────────────────────────────┘
```

Regras de level design:
- Todos os 4 dispositivos visíveis do spawn.
- Distância de interação: 2,5 m, com prompt bilíngue.
- Sem obstáculos que exijam pulo (movimento simples).
- Iluminação sem sombras em tempo real; luz direcional + ambiente.

## Dispositivos

| id | Nome | Ligado | Standby | Eco | Ação do jogador |
|---|---|---|---|---|---|
| `lampada_sala` | Lâmpada | 60 W | 0 W | — | apagar |
| `tv_sala` | TV | 110 W | 8 W | — | desligar (standby continua) |
| `ar_sala` | Ar-condicionado | 1400 W | 5 W | 550 W | ciclo: ligado → eco → desligado |
| `tomada_carregador` | Carregador | 5 W | 0 W | — | tirar da tomada |

O ciclo do ar-condicionado é genérico: qualquer dispositivo com `watt_eco > 0` alterna
`on → eco → off`; os demais alternam `on ↔ off`.

## NPC — Alex

- Colega de quarto, tom amigável, frases curtas (A1–A2).
- 4 árvores encadeadas (`dialogos/sala_01..04.json`), 9 objetivos físicos no total.
- 32 palavras/frases únicas no glossário da partida.
- Sem voz no MVP: texto em inglês + legenda em português.
- Escolhas sem cronômetro (tempo de leitura livre).

## Progressão

| Etapa | Evento | Recompensa |
|---|---|---|
| 1 | apagar a luz | vocabulário “turn off the light” |
| 2 | desligar a TV | vocabulário “turn off the TV” + dica de standby |
| 3 | colocar o ar no eco | vocabulário “eco mode” |
| 4 | tirar o carregador e acender a luz | “unplug the charger”, “turn on the light” |
| 5 | desligar o ar e apagar a luz | “turn off the air conditioner”, “energy meter” |
| 6 | ligar/desligar a TV e quiz | “kilowatt-hour”, “electricity bill” |
| fim | relatório | nota A–D + glossário da partida |

## HUD

- **Topo:** relógio (08:00 → 22:00), kW agora, kWh acumulado, R$, kg CO₂.
- **Lateral:** dispositivos “smart” com estado (ON/OFF/ECO) — camada de IoT simulada.
- **Centro:** caixa de diálogo (EN grande, PT menor).
- **Rodapé:** prompt de interação (“E — turn off the TV / desligar a TV”).
- **F1:** alterna EN+PT / EN / PT. **F3:** overlay de FPS. **F4:** encerra o dia (debug).
- O medidor e o prompt não são cobertos pela caixa de diálogo (layout testado em 1280×720).

## Relógio e ritmo

- Dia simulado: 08:00–22:00 (14 h).
- `escala_tempo = 120` → 1 s real = 2 min de jogo → **7 min reais** por partida.
- O tempo pausa durante o diálogo (leitura sem pressão).
- Botão de “pular para o fim do dia” apenas para debug.

## Relatório final

- Consumo do jogador × baseline (kWh).
- Economia (% e kWh), custo evitado (R$), CO₂ evitado (kg).
- Dispositivos esquecidos ligados.
- Vocabulário desbloqueado.
- Nota: A ≥30%, B ≥20%, C ≥10%, D <10%.

## Controles

| Entrada | Ação |
|---|---|
| WASD | andar |
| Mouse | olhar |
| E | interagir / avançar |
| 1–4 | escolher resposta |
| F1 | legenda |
| F3 | overlay de FPS |
| F4 | encerrar o dia (debug de apresentação) |
| Esc / clique | liberar/recapturar mouse |

## Direção de arte

- Low-poly, paleta quente (madeira, verde, azul petróleo).
- Sem sombras dinâmicas; luz direcional + ambiente.
- Resolução 1280×720, escala 3D 1.0 (reduzir para 0.8 se necessário).
- Fontes: uma sans-serif legível (Inter/Roboto) com bom contraste.

## Áudio (stretch)

- Clique de interruptor, bipe de eletrodoméstico, ambiente suave.
- Sem música no MVP; se entrar, precisa de licença CC0 documentada.

## Fora de escopo

Pulo, corrida, inventário, combate, multiplayer, celular, saves.
