# 03 — Sistema de diálogos

O objetivo é que **quem escreve não precise programar**. Todo o conteúdo fica em
`dialogos/*.json`, em português e inglês, e é validado automaticamente antes do merge.

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
| `on` | dispositivo ligado | ligar o ventilador |
| `eco` | dispositivo em modo econômico | ar-condicionado em eco |

Dispositivos válidos vêm de `dados/dispositivos.json`. Hoje:

`lampada_sala`, `tv_sala`, `ar_sala`, `tomada_carregador`.

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

Mensagens de erro apontam o nó e o campo:

```
Diálogo 'sala_01': nó 'objetivo_tv': 'next' aponta para nó inexistente: tv_ok2
```

## Boas práticas de escrita

| Faça | Evite |
|---|---|
| “Turn off the TV.” | “Would you be so kind as to disable the television?” |
| uma ideia por nó | parágrafos longos |
| repetir a estrutura (“turn off the ___”) | gírias regionais |
| dar contexto visual na dica | depender de conhecimento prévio |
| manter PT e EN com o mesmo sentido | tradução literal quebrada |

## Vocabulário do MVP

| Inglês | Português | Gatilho |
|---|---|---|
| turn off the light | apagar a luz | objetivo da lâmpada |
| turn off the TV | desligar a TV | objetivo da TV |
| eco mode | modo econômico | objetivo do ar |
| save energy | economizar energia | fim do dia |

Meta: ≥25 palavras/frases antes da entrega (adicionar em `vocab` nos nós).

## Teste do conteúdo

`testes/test_dialogos.gd` carrega `sala_01.json`, valida e exige:

- ≥10 nós;
- 3 objetivos físicos;
- todos os dispositivos existentes.

Se você mudar o diálogo e o teste quebrar, **o conteúdo está errado** (ou o teste precisa
ser atualizado junto, no mesmo PR).
