# 03 — Sistema de diálogos

O objetivo é que **quem escreve não precise programar**. Todo o conteúdo fica em
`dialogos/*.json`, em português e inglês, e é validado automaticamente antes do merge.

## Conteúdo do MVP

| Arquivo | Título | Objetivos |
|---|---|---|
| `sala_01.json` | Primeiro dia na sala | apagar a luz, desligar a TV, ar no eco |
| `sala_02.json` | Carregador e luminária | tirar o carregador, acender a luz |
| `sala_03.json` | Medidor de energia | desligar o ar, apagar a luz |
| `sala_04.json` | Vocabulário do consumo | ligar a TV, desligar a TV + quiz |

Os quatro são encadeados pela `Main` na ordem acima. Ao terminar um, o jogo abre o
próximo e só libera o relógio entre eles por 0,35 s. Ao fim do quarto, o tempo volta a
correr e o jogador pode explorar até 22:00 (ou usar `F4` no modo demo).

## Formato

```json
{
  "id": "sala_01",
  "titulo": "Primeiro dia na sala",
  "start": "intro",
  "nodes": {
    "intro": {
      "speaker": "Alex",
      "en": "Hey! You must be the new roommate.",
      "pt": "Ei! Você deve ser o novo colega de quarto.",
      "choices": [
        { "en": "Hi! Nice to meet you.", "pt": "Oi! Prazer em conhecer.", "next": "pedido" }
      ]
    },
    "pedido": {
      "speaker": "Alex",
      "en": "Could you turn off the TV?",
      "pt": "Você pode desligar a TV?",
      "objective": { "device": "tv_sala", "state": "off" },
      "next": "fim"
    },
    "fim": {
      "speaker": "Alex",
      "en": "Nice! That's 'turn off the TV'.",
      "pt": "Boa! Isso é 'turn off the TV'.",
      "vocab": [{ "en": "turn off the TV", "pt": "desligar a TV" }],
      "end": true
    }
  }
}
```

## Campos

### Diálogo

| Campo | Obrigatório | Descrição |
|---|---|---|
| `id` | sim | identificador único; deve ser igual ao nome do arquivo sem `.json` |
| `titulo` | não | nome legível para o menu/debug |
| `descricao` | não | resumo do conteúdo |
| `start` | sim | id do primeiro nó |
| `nodes` | sim | mapa `id → nó` |

### Nó

| Campo | Obrigatório | Descrição |
|---|---|---|
| `speaker` | sim | quem fala (`Alex`, `Você`, `Narrador`) |
| `en` | sim | fala em inglês (sem vazio) |
| `pt` | sim | tradução/legenda em português |
| `next` | condicional | próximo nó após E/clique |
| `choices` | condicional | 1–4 alternativas; cada uma com `en`, `pt` e `next` |
| `end` | condicional | encerra o diálogo |
| `objective` | condicional | exige ação física: `{ "device": "...", "state": "on/off/eco" }` |
| `vocab` | não | lista de `{ "en", "pt" }` desbloqueada ao entrar no nó |

**Regra de saída:** todo nó precisa de `end`, `next`, `choices` ou `objective`.
Nó com `objective` também precisa de `next` (para onde ir depois da ação).

## Objetivos físicos

| Estado | Significa | Exemplo |
|---|---|---|
| `off` | dispositivo desligado | apagar a luz |
| `on` | dispositivo ligado | ligar a TV |
| `eco` | dispositivo em modo econômico | ar-condicionado em eco |

Dispositivos válidos vêm de `dados/dispositivos.json`:
`lampada_sala`, `tv_sala`, `ar_sala`, `tomada_carregador`.

O `DialogueManager` compara o estado **depois de cada mudança** (`device_changed`).
Se o estado pedido já vale quando o nó aparece (por exemplo, o jogador apagou a luz
antes de receber o pedido), o objetivo completa sozinho — sem travar o diálogo para
sempre. Isso também cobre o reinício da partida.

## Vocabulário (32 entradas)

| Inglês | Português | Gatilho |
|---|---|---|
| turn off the light | apagar a luz | sala_01/luz_ok |
| light | luz | sala_01/luz_ok |
| turn off the TV | desligar a TV | sala_01/tv_ok |
| TV | televisão | sala_01/tv_ok |
| eco mode | modo econômico | sala_01/ar_ok |
| air conditioner | ar-condicionado | sala_01/ar_ok |
| watt | watt (unidade de potência) | sala_01/ar_ok |
| save energy | economizar energia | sala_01/fim |
| energy | energia | sala_01/fim |
| unplug the charger | tirar o carregador da tomada | sala_02/charger_ok |
| charger | carregador | sala_02/charger_ok |
| phone | celular | sala_02/charger_ok |
| turn on the light | acender a luz | sala_02/luz_on_ok |
| light switch | interruptor de luz | sala_02/luz_on_ok |
| standby | modo de espera | sala_02/fim |
| outlet | tomada | sala_02/fim |
| turn off the air conditioner | desligar o ar-condicionado | sala_03/ar_off_ok |
| energy meter | medidor de energia | sala_03/ar_off_ok |
| cool | frio, fresco | sala_03/ar_off_ok |
| kilowatt | quilowatt | sala_03/luz_off_ok |
| measure | medir | sala_03/luz_off_ok |
| less energy | menos energia | sala_03/fim |
| numbers | números | sala_03/fim |
| turn on the TV | ligar a TV | sala_04/tv_on_ok |
| screen | tela | sala_04/tv_on_ok |
| standby power | energia em standby | sala_04/tv_off_ok |
| small | pequeno | sala_04/tv_off_ok |
| kilowatt-hour | quilowatt-hora | sala_04/quiz_correct |
| electricity bill | conta de luz | sala_04/quiz_correct |
| carbon dioxide | dióxido de carbono | sala_04/quiz_correct |
| report | relatório | sala_04/fim |
| savings | economia | sala_04/fim |

## Como escrever (fluxo do roteirista)

1. Copie um diálogo existente como base.
2. Escreva primeiro em inglês; depois a legenda em português.
3. Frases curtas (máx. ~12 palavras), nível A1–A2.
4. 2–4 escolhas por nó; pelo menos uma escolha “não entendi” é bem-vinda.
5. Cada objetivo precisa de uma dica clara (“Walk to the TV and press E”).
6. Sempre dê vocabulário novo no nó de sucesso (`vocab`).
7. Rode a validação antes do PR:

```bash
godot --headless --path . --script testes/run_tests.gd
```

### Erros comuns que o validador pega

```
Diálogo 'sala_01': nó 'objetivo_tv': 'next' aponta para nó inexistente: tv_ok2
Diálogo 'sala_01': nó órfão (inacessível a partir de 'intro'): dica_extra
Diálogo 'sala_01': nó 'fim': 'end' não pode ter 'next' nem 'choices'
```

## O que o validador verifica

- Campos obrigatórios e textos não vazios.
- `start` existe.
- Todo `next` (de nó e de escolha) existe.
- Nenhum nó órfão (inacessível a partir do `start`).
- `end` não misturado com `next`/`choices`.
- Máximo de 4 escolhas.
- `objective.device` existe em `dados/dispositivos.json`.
- `objective.state` é `on`, `off` ou `eco`.
- `vocab` tem `en` e `pt`.

## Testes

`testes/test_dialogos.gd` exige 4 arquivos, valida todos, confere nó inicial, objetivos,
nó final e **≥25 entradas únicas** no glossário. `testes/test_fluxo.gd` percorre as quatro
árvores de verdade: escolhe opções, tenta uma ação errada, executa a certa e verifica que
o diálogo só avança depois da ação.

Se você mudar o diálogo e o teste quebrar, **o conteúdo está errado** (ou o teste precisa
ser atualizado junto, no mesmo PR).
