# 05 — Cronograma

O prazo da atividade ainda não foi definido, então o cronograma é **relativo**: cada fase
tem um gate objetivo e só avança quando o gate passa. Ritmo assumido: 8–10 h/semana por
pessoa (≈ 4–5 semanas no total).

## Estado em 24/10/2026

| Fase | Estado | Evidência |
|---|---|---|
| **0. Fundação** | ✅ concluída | CI, testes, build web |
| **1. Vertical slice** | ✅ concluída | sala, player, 4 devices, HUD, teste de input |
| **2. Diálogo** | ✅ concluída | 4 árvores, caixa com typewriter/escolhas, objetivo travado |
| **3. Conteúdo e arte** | ✅ concluída | 32 palavras, relatório, balanceamento, props procedurais |
| **4. Polimento** | ✅ concluída | 227 testes, ~96 FPS em software (faixa 90–100), acessibilidade |
| **5. Entrega** | ⏳ parcial | README/GIF/builds prontos; faltam vídeo, ensaio presencial, tag/push e convites |

## Visão geral

| Fase | Duração | Objetivo | Gate |
|---|---|---|---|
| **0. Fundação** | 2–3 dias | repo, Godot, CI, prova de vida | build web do cubo abre + CI verde |
| **1. Vertical slice** | 1 semana | sala blockout + player + 4 devices + HUD | desligar a luz muda o HUD em <1 s |
| **2. Diálogo** | 1 semana | loader, caixa, 1 árvore integrada | NPC pede e o jogo só avança após a ação |
| **3. Conteúdo e arte** | 1 semana | props finais, 4 diálogos, relatório | partida completa 08:00–22:00 sem erro |
| **4. Polimento** | 3–5 dias | UI, áudio, acessibilidade, performance | ≥30 FPS no PC fraco; 0 bug bloqueante |
| **5. Entrega** | 2–3 dias | README com GIF, vídeo, slides, tag | ensaio da demo em 5 min |

## Fase 0 — Fundação (concluída)

- [x] Godot 4.6.3 instalado e projeto criado.
- [x] Estrutura de pastas e propriedade definidas.
- [x] 4 autoloads com sinais e stubs funcionais.
- [x] `dados/` e `dialogos/sala_01.json` validados por teste.
- [x] Testes headless (30 verificações) verdes.
- [x] CI + export web.
- [x] Documentação 0.1.

**Gate:** `godot --headless --path . --script testes/run_tests.gd` → OK.
Build web gerado. Teste de FPS no PC fraco fica como primeira tarefa da Fase 1.

## Fase 1 — Vertical slice (concluída)

| Responsável | Tarefa |
|---|---|
| Gian | blockout da sala, player FPS, 4 props com colisão, luz |
| Matheus | interação E, prompt bilíngue, ligação com `EnergyManager` |
| Terceiro | HUD ligado aos sinais, painel de dispositivos, teste de FPS |

**Gate:** andar pela sala, mirar na TV, apertar E e ver `kW`/`kWh` caírem.

## Fase 2 — Diálogo (concluída)

| Responsável | Tarefa |
|---|---|
| Matheus | `DialogueManager` completo, `CaixaDialogo` com typewriter e escolhas, integração de `objective` |
| Gian | cena da caixa de diálogo, cartão de vocabulário, layout do HUD |
| Terceiro | testes de fluxo (objetivo → ação → avanço), relatório de erros |

**Gate:** Alex pede “turn off the TV”; o diálogo fica travado até a TV ser desligada.

## Fase 3 — Conteúdo e arte (concluída)

| Responsável | Tarefa |
|---|---|
| Gian | props low-poly finais, materiais, iluminação, ajuste de performance |
| Matheus | 4 diálogos, ≥25 palavras, revisão de nível A1–A2 |
| Terceiro | relatório final, tela de fim de dia, balanceamento do baseline |

**Gate:** partida completa do início ao relatório, sem erro no console.

## Fase 4 — Polimento (concluída)

- Acessibilidade: contraste, tamanho de fonte, legenda sempre disponível.
- Áudio (se houver): CC0 documentado.
- Performance: medir FPS, reduzir draw calls, testar no PC fraco.
- QA: checklist de 22 casos (interações, escolhas, reinício, web).
- Correção de bugs com label `tipo:bug`.

**Gate:** ≥30 FPS no PC fraco, 0 bug bloqueante, build web atualizado.

## Fase 5 — Entrega (parcial)

- README com GIF e link do build.
- Vídeo de 3 min: pitch → gameplay → arquitetura → energia → limitações.
- Slides de 8–10 páginas.
- Ensaio cronometrado (5 min).
- Tag `v1.0` e release no GitHub.
- Formulário de avaliação da demo (opcional).

**Gate:** ensaio sem travar, link do Pages funcionando em outro computador.

## Rituais

| Ritual | Frequência | Duração | Saída |
|---|---|---|---|
| Sync geral | semanal | 30 min | 3 prioridades da semana |
| Check-in assíncrono | diário | 2 min | feito / próximo / bloqueio |
| Revisão de PR | contínua | — | em até 24 h |
| Playtest interno | fim de fase | 15 min | 3 bugs + 1 ajuste |

## Backlog imediato (Fase 1 — concluído)

1. ~~`art`: blockout da sala com medidas e spawn.~~
2. ~~`feat`: `Player.tscn` com `CharacterBody3D` + câmera.~~
3. ~~`feat`: `Interactor` + prompt bilíngue.~~
4. ~~`feat`: `EnergyDevice` como nó de cena, ligado ao `EnergyManager`.~~
5. ~~`feat`: HUD com relógio e medidor.~~
6. ~~`test`: medir FPS no PC fraco e registrar no issue.~~ (medido em software: 90–100 FPS)

## Próximos passos (entrega)

1. `docs`: gravar o vídeo de 3 min seguindo `docs/12-ROTEIRO-VIDEO.md`.
2. `docs`: ensaiar a apresentação de 5 min (`docs/11-SLIDES-E-ENSAIO.md`).
3. `infra`: push de `dev` → `main`, tag `v1.0`, release com builds Linux/Windows/Web.
4. `infra`: convidar os três colaboradores e subir a proteção da `main` para 1 aprovação.

## Plano B por tempo

| Se o prazo for… | Corte |
|---|---|
| 4 semanas | fundir Fases 3 e 4; 2 diálogos; sem áudio |
| 3 semanas | 1 diálogo; sem relatório animado; arte blockout |
| 2 semanas | demo linear de 1 objetivo + medidor (ainda defensável) |

## Riscos

| Risco | Sinal | Ação |
|---|---|---|
| Godot pesado no PC fraco | <30 FPS na Fase 1 | Godot 3.6 ou 2 objetos |
| Conflito de `.tscn` | merge com marcadores no arquivo | parar, revisar contrato de cenas |
| Escopo inflar | issue nova sem label de fase | mover para milestone v2 |
| Terceiro sobrecarregado | atraso no HUD | Gian assume UI visual, Matheus assume testes |
