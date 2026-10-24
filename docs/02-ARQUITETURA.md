# 02 — Arquitetura

## Visão geral

```
┌────────────────────────────────────────────────────────────┐
│                        Autoloads                           │
│  GameState   EnergyManager   DialogueManager   SceneRouter  │
└───────┬──────────────┬───────────────┬─────────────┬───────┘
        │              │               │             │
        │        ┌─────▼─────┐   ┌─────▼─────┐       │
        │        │  EnergyBus │   │  JSON de  │       │
        │        │ (IoT sim.) │   │  diálogo  │       │
        │        └───────────┘   └───────────┘       │
        │              │               │             │
        ▼              ▼               ▼             ▼
   HUD / UI      Dispositivos     CaixaDialogo   troca de cena
```

## Autoloads (ordem de inicialização)

| # | Autoload | Arquivo | Papel |
|---|---|---|---|
| 1 | `GameState` | `scripts/autoload/GameState.gd` | idioma, modo de legenda, pausa, vocabulário |
| 2 | `EnergyManager` | `scripts/autoload/EnergyManager.gd` | relógio, dispositivos, consumo, baseline, relatório |
| 3 | `DialogueManager` | `scripts/autoload/DialogueManager.gd` | carrega/valida diálogos, estados e objetivos |
| 4 | `SceneRouter` | `scripts/autoload/SceneRouter.gd` | troca de cenas |

A ordem importa: `DialogueManager._ready()` conecta em `EnergyManager.device_changed`.

## Sinais

```gdscript
// EnergyManager
device_changed(device_id, is_on, watts)
energy_updated(kwh, cost_brl, co2_kg, kw_now)
clock_updated(clock_minutes)
day_finished(report)
vocabulary_unlocked(entry)

// DialogueManager
dialogue_started(id)
line_shown(node)
choices_shown(choices)
objective_requested(device_id, state)
objective_completed(device_id)
vocabulary_unlocked(entry)
dialogue_finished(id)

// GameState
language_changed(code)
subtitle_mode_changed(mode)
paused_changed(is_paused)
```

## Integração diálogo ↔ energia

Este é o contrato que sustenta o projeto:

1. `DialogueManager` chega em um nó com `objective` e emite `objective_requested`.
2. `EnergyManager` continua simulando e emite `device_changed` a cada interação.
3. `DialogueManager` compara o dispositivo e o estado; se casar, avança para o `next`.
4. Enquanto o diálogo está ativo, `EnergyManager.paused = true` (o tempo não corre).

Consequência: **não existe caminho de código em que o jogador “passe” de um pedido sem
executar a ação física.**

## Contrato de cenas (anti-conflito no Git)

| Regra | Motivo |
|---|---|
| Cada `.tscn` tem **um único dono** | evita merge conflicts binários/textuais |
| Nós usados por script têm **nome único** (`%Nome`) | scripts não dependem de caminho |
| Scripts usam só `%Nome` ou `@export` | sobrevive a mudanças de hierarquia |
| Proibido `get_node("../../..")` | quebra fácil e não é revisável |
| `project.godot` só o Gian edita | autoloads/input map são globais |

Se um script precisar de um nó novo, o dono da cena abre issue e adiciona o nó.
Ninguém abre a cena de outra pessoa no editor.

## Estrutura de dados

### `dados/dispositivos.json`

Lista de dispositivos com consumo. A simulação lê os watts daqui; a UI usa `nome_pt`/`nome_en`.

### `dados/config.json`

Tarifa, fator de CO₂, escala de tempo, início/fim do dia e meta de economia.

### `dados/baseline.json`

Perfil fixo de desperdício (`horas_ligado`). O baseline é **calculado** pela mesma
função de consumo — não é um número digitado.

### `dialogos/*.json`

Árvores de diálogo validadas por `DialogueValidator`. Formato em `docs/03-DIALOGOS.md`.

## Camada de IoT simulada

`EnergyBus` publica mensagens em memória no formato:

```json
{ "topic": "home/sala/tv_sala/state",
  "payload": { "ligado": false, "modo": "off", "watts": 8 } }
```

- Usado pelo HUD (painel de dispositivos) e pelos testes.
- **Não é MQTT real.** Em `docs/09-RELATORIO-BANCA.md` isso está declarado como simulação.
- Stretch: trocar o transporte por MQTT (Mosquitto) sem mudar a interface dos dispositivos.

## Performance (PC fraco)

| Configuração | Valor |
|---|---|
| Renderer | `gl_compatibility` |
| MSAA / screen-space AA | desligados |
| Sombras em tempo real | desligadas |
| Escala 3D | 1.0 (fallback 0.8) |
| Resolução | 1280×720 |
| Orçamento de triângulos | < 50k na cena |
| Luzes dinâmicas | ≤ 3 |

Teste obrigatório na Fase 0/1: FPS no PC mais fraco da equipe. Se <30 FPS, plano B:
Godot 3.6 ou reduzir a sala a 2 objetos interativos.

## Testes

| Arquivo | Cobre |
|---|---|
| `testes/test_dialogos.gd` | JSON válido, referências, órfãos, objetivos, campos vazios |
| `testes/test_energia.gd` | consumo, eco, baseline, relatório, simulação de 1 h |

Runner: `testes/run_tests.gd` (sem addons). Retorna código 1 em falha, o que quebra o CI.

## Decisões registradas

| Decisão | Alternativa descartada | Motivo |
|---|---|---|
| JSON para diálogos | Resources `.tres` | roteirista edita sem abrir o Godot |
| Validador próprio | addon de diálogo | menos dependência, regras do projeto |
| Simulação em tempo real | energia só no fim | a banca cobra mecânica, não tela final |
| Baseline calculado | número fixo | defensável e testável |
| Sem threads no web | export com threads | GitHub Pages não envia COOP/COEP |
