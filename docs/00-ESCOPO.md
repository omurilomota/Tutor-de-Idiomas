# 00 — Escopo

## Problema

Aprender inglês exige prática em contexto, mas cursos tradicionais separam vocabulário
da ação. Ao mesmo tempo, eficiência energética costuma ser ensinada como teoria, sem
consequência visível. O projeto une os dois: o jogador aprende inglês **fazendo** escolhas
que mudam o consumo de energia da casa.

## Objetivo

Entregar um **serious game 3D em primeira pessoa**, jogável no navegador, no qual o
jogador conversa com um colega de quarto nativo e executa pedidos domésticos em inglês,
reduzindo o consumo de energia em relação a um baseline de desperdício.

## Público

- Estudantes de inglês de nível A1–A2 (ensino médio/técnico).
- Professores que querem uma demo curta para ilustrar vocabulário de casa e consumo.
- Banca avaliadora de um projeto integrador de TI.

## Proposta de valor

| Para o jogador | Para o professor | Para a banca |
|---|---|---|
| prática de vocabulário com consequência imediata | demo de 5–10 min, sem instalação | integra 3D, estado, dados e testes |

## Escopo do MVP

### Dentro

- 1 cômodo: sala de estar low-poly.
- 4 dispositivos: lâmpada, TV, ar-condicionado e carregador.
- 1 NPC (Alex) com 1 árvore de diálogo, ≥10 nós e 3 objetivos físicos.
- Medidor ao vivo: kW, kWh, R$, CO₂ e relógio.
- Relatório final com economia vs. baseline, vocabulário e nota.
- UI bilíngue (inglês principal + legenda em português).
- Build web + desktop Linux e Windows.
- Testes automatizados de diálogo e energia no CI.

### Fora

- Cozinha e banheiro (backlog v2).
- Voz sintetizada (TTS) e dublagem.
- LLM em tempo real.
- Multiusuário/metaverso, VR e AR.
- Save/load, mobile, loja de upgrades.

## Critérios de aceite

1. Abre no Godot 4.6 sem erros.
2. ≥30 FPS no PC fraco da equipe; meta de 60 FPS no PC de desenvolvimento.
3. Build web jogável no navegador, sem instalação.
4. Ação física altera o medidor em <1 s e destrava o diálogo.
5. Relatório fecha a conta: `economia = baseline − consumo do jogador`.
6. CI verde; `main` protegida; PRs revisados.
7. README com GIF, controles, stack e créditos.
8. Vídeo demo de 3 min e ensaio de apresentação de 5 min.

## Métricas de sucesso da demo

| Métrica | Meta |
|---|---|
| Tempo de partida | 5–8 min |
| Palavras/frases no glossário | ≥25 |
| Objetivos físicos | 3 por partida |
| Redução mínima para “passar” | 20% vs. baseline |
| FPS no PC fraco | ≥30 |
| Erros no console | 0 |

## Cobertura dos temas da atividade

| Tema | Cobertura | Como defender |
|---|---|---|
| Metaverso | **Parcial** | Mundo 3D navegável, mas single-player; não alegar metaverso |
| IoT | **Simulado** | Barramento de eventos com tópicos `home/sala/<device>/state`; declarar que é simulação, não MQTT real |
| AR | **Não** | Fora do escopo; não maquiar |
| VR | **Não** | First-person ≠ VR; citar OpenXR como trabalho futuro |
| Eficiência energética | **Sim, mecânica central** | Ação do jogador altera o consumo em tempo real e o relatório fecha a conta |

**Alinhamento obrigatório:** confirmar com o professor se a ausência de AR é aceitável.
Se AR for obrigatório, este projeto não cobre o requisito.

## Premissas e restrições

- Sem orçamento: apenas assets gratuitos e ferramentas open source.
- Equipe de 3 pessoas, 8–10 h/semana cada.
- Sem internet garantida na apresentação: a demo roda offline (build local ou web já carregado).
- Sem conhecimento prévio de modelagem 3D: usar kits low-poly prontos.
