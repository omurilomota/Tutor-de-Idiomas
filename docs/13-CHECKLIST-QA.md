# 13 — Checklist de QA (22 casos)

**Legenda:** ✅ automatizado no runner ou verificado no build · 🟡 verificado por
inspeção/captura. Nenhum caso fica pendente (⏳) nesta entrega.

O runner `testes/run_tests.gd` cobre os casos marcados ✅ (7 suítes: diálogos,
energia, fluxo, cenas, partida, UI e input). Os prints vêm de
`docs/img/` e foram gerados a partir da cena real em 1280×720; o build web foi
aberto em Chrome **e** Firefox headless com captura real do canvas
([`img/web-firefox.png`](img/web-firefox.png),
[`img/web-chrome.png`](img/web-chrome.png)).

| # | Caso | Como foi verificado | Status |
|---|---|---|---|
| 1 | Projeto abre no Godot 4.6.3 sem erro | `--headless --import` | ✅ |
| 2 | Cena principal inicia com relógio 08:00 e 4 dispositivos ON | `test_partida` + captura | ✅ |
| 3 | WASD anda na direção da câmera | `test_input` (12 ticks) | ✅ |
| 4 | Mouse olha com limite vertical de 80° | `test_input` + inspeção do clamp | ✅ |
| 5 | Raycast de 2,5 m detecta a lâmpada | `test_input` | ✅ |
| 6 | E desliga a lâmpada e o prompt troca | `test_input` | ✅ |
| 7 | TV alterna ON ↔ OFF e mantém standby de 8 W | `test_energia` + dados | ✅ |
| 8 | Ar ciclo ON → ECO → OFF (550 W no eco) | `test_energia` | ✅ |
| 9 | Carregador alterna ON ↔ OFF | `test_energia` + fluxo | ✅ |
| 10 | Ação errada não avança o diálogo | `test_fluxo` | ✅ |
| 11 | Ação certa avança e desbloqueia vocabulário | `test_fluxo` | ✅ |
| 12 | Tempo pausa no diálogo e volta ao normal | `test_fluxo` | ✅ |
| 13 | Escolhas 1–4 por teclado e clique | `test_fluxo` (escolha) + `test_ui` (tecla `1–4` e clique na opção) | ✅ |
| 14 | F1 alterna EN+PT / EN / PT | `test_input` | ✅ |
| 15 | F3 mostra o overlay de FPS | `test_input` | ✅ |
| 16 | Fim do dia pelo relógio mostra exatamente um relatório | `test_energia` | ✅ |
| 17 | Relatório mostra consumo, baseline, %, R$, CO₂, nota e glossário | `test_partida` + captura | ✅ |
| 18 | Reiniciar funciona sem recarregar o jogo | `test_partida` | ✅ |
| 19 | Build web abre e roda no Chrome | Chrome 156 headless + SwiftShader: WebGL 2.0, canvas 1280×720, pointer lock após clique | ✅ |
| 20 | Build web abre no Firefox | Firefox 155 headless (Playwright): WebGL 2.0, canvas 1280×720, 0 erros de console, jogo renderizando com HUD e diálogo | ✅ |
| 21 | F4 encerra o dia na apresentação | `test_input` | ✅ |
| 22 | Reinício profundo restaura estados e evita referência velha | `test_partida` + correção documentada | ✅ |

## Matriz de dispositivos

| Dispositivo | ON | ECO | OFF | Prompt EN/PT | Glow/visual |
|---|---|---|---|---|---|
| Lâmpada | 60 W | — | 0 W | ✅ | ✅ |
| TV | 110 W | — | 8 W standby | ✅ | ✅ |
| Ar | 1400 W | 550 W | 5 W standby | ✅ | ✅ |
| Carregador | 5 W | — | 0 W | ✅ | ✅ |

## Roteiro de regressão manual (10 min)

1. Abrir `godot --path .`, jogar do início ao relatório usando `F4` no fim.
2. Em cada objetivo, apertar `E` no aparelho errado primeiro (não deve avançar).
3. Alternar `F1` três vezes e conferir EN/PT.
4. Abrir o relatório, clicar em “Jogar de novo”, verificar 08:00 e dispositivos ON.
5. Repetir no build web em Chrome e Firefox, com o servidor local.
6. Verificar `Esc` (mouse) e `F3`.
7. Fechar e abrir de novo; nenhum erro no console.

## Critério de saída

- 0 falha no runner (`Verificações: 227 | Falhas: 0`).
- 0 erro no console do Godot e do navegador (Chrome e Firefox).
- ≥30 FPS no PC fraco; referência de software: 90–100 FPS (última medição: 96,3).
- Nenhum caso pendente antes da entrega; sobram só tarefas humanas (gravar o vídeo,
  ensaiar a apresentação e publicar a tag `v1.0`).
