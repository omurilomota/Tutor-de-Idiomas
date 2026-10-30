# 09 — Relatório para a banca

## Resumo do projeto

**Home Switch** é um serious game 3D em primeira pessoa para aprender inglês e eficiência
energética. O jogador conversa com Alex, um colega de quarto nativo, e só avança no diálogo
quando executa o pedido na casa. Cada ação altera o consumo em tempo real; no fim do dia,
um relatório compara o consumo do jogador com um baseline de desperdício calculado pela
mesma simulação.

## Resultados medidos

| Métrica | Resultado | Evidência |
|---|---|---|
| Conteúdo | 4 diálogos, 9 objetivos, 32 palavras/frases | `dialogos/` + teste |
| Testes automatizados | **227 verificações, 0 falhas** | `testes/run_tests.gd` |
| Performance | **≈90–100 FPS** a 1280×720 em llvmpipe (software) | `tools/benchmark_fps.gd` |
| Baseline | 22,05 kWh/dia | `dados/baseline.json` |
| Partida ótima | 7,812 kWh → **64,6%** de economia, nota A | `docs/img/relatorio.png` |
| Builds | Web + Linux + Windows exportados | `export_presets.cfg` |
| Fim do dia | relógio 08:00→22:00 e relatório com 1 clique | teste de energia + tela |

## Cobertura dos temas

| Tema | Cobertura | Argumento técnico |
|---|---|---|
| Metaverso | **Parcial** | Ambiente 3D navegável e persistente durante a partida, mas **single-player**. Não é um metaverso multiusuário. |
| IoT | **Simulado** | Barramento de eventos com tópicos `home/sala/<device>/state`, estados publicados e consumidos pelo HUD. **Não usa broker MQTT real**; a interface permite trocar o transporte depois. |
| AR | **Não coberto** | Fora do escopo. Não há rastreamento de câmera nem sobreposição no mundo real. |
| VR | **Não coberto** | First-person não é VR. OpenXR está listado como trabalho futuro. |
| Eficiência energética | **Coberto como mecânica** | Ações alteram kW/kWh/R$/CO₂ em tempo real; o relatório fecha a conta contra um baseline calculado. |

**Posição honesta:** 3 temas sólidos (IoT simulado, energia, mundo 3D) + 1 parcial
(metaverso) + 1 ausente (AR). Se AR for requisito obrigatório, o projeto não atende.

## Decisões técnicas e justificativas

| Decisão | Por quê |
|---|---|
| Godot 4.6 com renderer Compatibility | roda em PC fraco, exporta para web, sem custo de licença |
| GDScript | iteração rápida, sem build step, fácil para a equipe |
| Diálogo em JSON | roteirista edita sem programar; validação automatizada no CI |
| Árvore roteirizada em vez de LLM | offline, determinístico, testável, sem custo e sem risco de conteúdo impróprio |
| Energia em tempo real | o tema vira mecânica, não tela final |
| Baseline calculado | a economia é reproduzível e auditável, não um número inventado |
| Sem threads no export web | GitHub Pages não envia COOP/COEP; build não-threaded funciona |
| Testes headless próprios | zero dependências, roda no CI em segundos |

## O que é simulado (e assumimos)

1. **IoT:** os dispositivos publicam em um barramento em memória, não em MQTT.
2. **Tarifa e CO₂:** valores didáticos configuráveis (R$ 0,75/kWh e 0,084 kg/kWh),
   não uma medição da conta do jogador.
3. **Baseline:** perfil fixo de desperdício, não dados reais de uma residência.
4. **Consumo dos aparelhos:** potências típicas de etiqueta, sem curvas reais de uso.

Dizer isso na apresentação vale mais do que esconder.

## Limitações

- 1 cômodo e 4 dispositivos no MVP.
- Sem voz/TTS; texto + legenda.
- Sem LLM: a conversa é uma árvore finita.
- Sem multiusuário, AR ou VR.
- Sem save/load.
- Modelo energético simplificado (potência constante).
- Sem áudio no MVP (clique, bipe e ambiente ficaram como stretch).
- Sem teste com usuários reais: a eficácia pedagógica é argumentada, não medida.
- O baseline é um perfil fixo, não a conta real de uma residência.
- Performance medida em renderizador por software, não no PC fraco físico da equipe.

## Trabalhos futuros

| Curto prazo | Médio prazo | Longo prazo |
|---|---|---|
| cozinha e banheiro | MQTT real com Mosquitto | LLM com moderação e custo controlado |
| TTS local (Piper) | VR com OpenXR | multiplayer cooperativo |
| mais diálogos e vocabulário | analytics de aprendizado | AR para apontar aparelhos |
| export Android | acessibilidade ampliada | integração com dados reais de consumo |

## Roteiro da demo (5 minutos)

| Tempo | O que mostrar |
|---|---|
| 0:00–0:30 | problema: inglês descontextualizado + energia invisível |
| 0:30–1:00 | pitch e objetivo |
| 1:00–3:30 | gameplay: apagar a luz, desligar a TV, ar no eco e carregador (medidor reagindo) |
| 3:30–4:15 | relatório final (F4): baseline 22,05 kWh, economia 64,6%, R$, CO₂, nota A |
| 4:15–4:45 | arquitetura: autoloads, JSON, validação, CI |
| 4:45–5:00 | limitações e trabalhos futuros |

## Perguntas prováveis da banca

**“Isso é metaverso?”**
Não. É um mundo 3D single-player. Cobre imersão espacial, não a camada social persistente
que define metaverso.

**“O IoT é real?”**
É uma simulação de barramento de eventos com tópicos no padrão MQTT. O transporte é
isolado, então trocar por um broker real é uma evolução de baixo impacto.

**“Por que não usaram IA generativa?”**
Custo, dependência de internet, latência e imprevisibilidade de conteúdo em uma demo
avaliada. A arquitetura isola o provedor de diálogo: um LLM pode entrar como
`DialogueProvider` sem mudar o resto do jogo.

**“A economia de energia é real?”**
O cálculo é fisicamente correto (`W × h / 1000`), mas as potências e a tarifa são
parâmetros didáticos. O baseline usa a mesma fórmula, então a comparação é justa.

**“Como vocês garantem que o jogo ensina?”**
Vocabulário ligado a ações físicas, repetição de estrutura (“turn off the ___”), legenda
em PT, sem cronômetro e glossário no fim. O próximo passo é um teste com usuários.

**“O que acontece se o jogador não entender inglês?”**
Ele vê a legenda em português e dicas contextuais; pode escolher “I don't understand” e
recebe uma explicação mais simples.

**“Qual foi a maior dificuldade técnica?”**
A integração diálogo↔energia: o diálogo precisa esperar um evento do mundo físico sem
travar a UI. Resolvemos com uma máquina de estados e o estado `objective`. Também
tivemos um bug de referência antiga quando o dia reiniciava: o `EnergyManager` recarregava
o JSON e os nós 3D ficavam apontando para objetos velhos; a correção foi resetar os
dispositivos no lugar (documentada em `docs/02-ARQUITETURA.md`).

**“Como foi a divisão do time?”**
Um dono por pasta, contrato de cenas com nomes únicos e PRs pequenos. O CI impede merge
com diálogo inválido.

## Evidências para anexar

- Link do build web (GitHub Pages).
- Print do CI verde.
- `docs/img/gameplay.gif`, `inicio.png`, `objetivo.png`, `vocabulario.png` e `relatorio.png`.
- Vídeo de 3 min (roteiro em `docs/12-ROTEIRO-VIDEO.md`).
- Slides e ensaio (doc 11).
- Histórico de PRs (mostra o processo).
