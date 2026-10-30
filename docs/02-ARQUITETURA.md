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

## Cenas e nós

| Cena | Script | Papel |
|---|---|---|
| `cenas/main/Main.tscn` | `scripts/main/Main.gd` | orquestra dia, sequência de 4 diálogos, fim do dia e reinício |
| `cenas/salas/SalaEstar.tscn` | — | sala, móveis, spawn, 4 nós `EnergyDevice3D` |
| `cenas/player/Player.tscn` | `PlayerController.gd` + `Interactor.gd` | FPS, câmera e raycast de 2,5 m |
| `cenas/ui/HUD.tscn` | `HUD.gd` + `MedidorEnergia.gd` | relógio, medidor, dispositivos, prompt, objetivo, FPS |
| `cenas/ui/CaixaDialogo.tscn` | `CaixaDialogo.gd` | typewriter, escolhas 1–4, F1, bloqueio no objetivo |
| `cenas/ui/CartaoVocabulario.tscn` | `CartaoVocabulario.gd` | fila de cartões de vocabulário |
| `cenas/ui/TelaRelatorio.tscn` | `TelaRelatorio.gd` | relatório final e botão reiniciar |

`EnergyDevice3D` é um `StaticBody3D` na camada de colisão 2: o jogador anda na camada 1
e o `Interactor` só enxerga dispositivos. Cada nó guarda `device_id` e um filho `Glow`
(visível quando ligado), então o mesmo script serve para lâmpada, TV, ar e carregador.

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

**Medição feita:** `tools/benchmark_fps.gd` rodou a partida real a 1280×720 em
**llvmpipe** (renderizador por software da Mesa): **≈90–100 FPS** em 300 frames. Como o
llvmpipe é mais lento que a GPU integrada de um PC fraco, o gate de 30 FPS está coberto
por margem. O monitor de FPS do jogo fica em `F3`.

## Testes

| Arquivo | Cobre |
|---|---|
| `testes/test_dialogos.gd` | 4 árvores válidas, referências, órfãos, objetivos, campos vazios, ≥25 palavras |
| `testes/test_energia.gd` | consumo, eco, baseline, relatório, balanceamento, fim do dia pelo relógio, simulação de 1 h |
| `testes/test_fluxo.gd` | objetivo → ação → avanço, ação errada, pausa do tempo, sequência dos 4 diálogos |
| `testes/test_cenas.gd` | smoke: sala, 4 dispositivos, player, câmera, Interactor, UI e nós `%` |
| `testes/test_partida.gd` | partida completa: HUD, relatório, reinício sem trocar de cena |
| `testes/test_ui.gd` | caixa de diálogo: escolha por tecla (1–4) e clique, foco dos botões e os 3 modos do F1 |
| `testes/test_input.gd` | Input Map, WASD, mouse, raycast E, F1, F3 e F4 |

Runner: `testes/run_tests.gd` (sem addons). Retorna código 1 em falha, o que quebra o CI.
Total atual: **227 verificações**. O runner roda no primeiro frame do SceneTree, depois que
os autoloads executaram `_ready()` (as conexões de sinal ainda não existem em `_initialize`).

## Decisões registradas

| Decisão | Alternativa descartada | Motivo |
|---|---|---|
| JSON para diálogos | Resources `.tres` | roteirista edita sem abrir o Godot |
| Validador próprio | addon de diálogo | menos dependência, regras do projeto |
| Simulação em tempo real | energia só no fim | a banca cobra mecânica, não tela final |
| Baseline calculado | número fixo | defensável e testável |
| Reset dos devices no lugar | recarregar o JSON em `start_day()` | nós 3D guardam referência; recarregar deixava prompt/visual presos no estado antigo |
| Câmera mira via camada 2 | filtro por tipo no raycast | separa andar de interagir sem `get_node("../../")` |
| Sem threads no web | export com threads | GitHub Pages não envia COOP/COEP |
| Teste de física espera `physics_frame` | chamar `_physics_process` à mão no teste | `move_and_slide()` só lê contatos sincronizados no passo real do engine; com chamada manual o deslocamento variava entre 0,08 m e 0,85 m conforme o timing (teste intermitente). Com awaits de física o teste ficou determinístico (35/35 execuções verdes) |
