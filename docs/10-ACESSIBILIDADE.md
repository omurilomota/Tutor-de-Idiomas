# 10 — Acessibilidade

Revisão feita no build de 1280×720, renderer Compatibility, com foco em leitura,
teclado e legenda. Os critérios abaixo são verificáveis no jogo; o que não foi testado
está declarado no fim.

## Contraste

| Elemento | Fundo | Texto | Contraste aproximado |
|---|---|---|---|
| Caixa de diálogo | `#090D12` (α 0,95) | `#F5F7FA` | ~18:1 |
| Legenda PT | `#090D12` | `#C7D3DD` | ~12:1 |
| Painel de objetivo | `#1F4233` | `#E0F7E7` | ~9:1 |
| HUD (relógio/medidor) | `#0A0F14` (α 0,88) | `#D9E6F2` | ~15:1 |
| Prompt de interação | `#0A0F14` | `#FFFFFF` / `#B8CCD9` | ~16:1 / ~9:1 |
| Dica de continuar | `#090D12` | `#F2D173` | ~11:1 |
| Botão reiniciar | `#0E1319` | `#FFFFFF` | ~16:1 |

Todos os textos principais passam com folga no critério AA (4,5:1) e no AAA (7:1) para
texto normal. O estado dos dispositivos não depende só de cor: o painel escreve
`ON`, `OFF` ou `ECO` e o wattage.

## Tipografia e layout

- Inglês do diálogo: 22 px; português: 16 px; HUD: 15–24 px; relatório: 15–46 px.
- Nenhum texto essencial abaixo de 12 px (só a linha de ajuda e o rótulo de FPS).
- Caixa de diálogo com largura fixa de 830 px a 1280×720, margem de 300 px à esquerda
  para **não cobrir o medidor de energia**.
- O prompt fica acima da caixa de diálogo e o cartão de vocabulário abaixo do topo,
  sem sobrepor os indicadores de consumo.
- Linhas quebram automaticamente (`autowrap`); o relatório usa uma área de rolagem para
  o glossário de até 32 entradas.

## Legenda

- `F1` alterna **EN+PT → EN → PT → EN+PT**.
- O português está sempre disponível no modo `both` e `pt`; nenhum texto em inglês é
  obrigatório para executar uma ação.
- As escolhas também mostram EN e PT na mesma opção.
- A legenda não tem cronômetro: o tempo do jogo pausa enquanto o diálogo está aberto.

## Teclado e mouse

- WASD + mouse; `E` interage/avança; `1–4` escolhem; `F1` legenda; `F3` FPS;
  `F4` encerra o dia (debug); `Esc` libera o mouse.
- As escolhas são `Button`s focáveis e também aceitam número/clique.
- O botão “Jogar de novo (R)” recebe foco ao abrir o relatório e aceita `Enter`/`R`.
- Nenhuma escolha tem limite de tempo.
- O mouse pode ser liberado com `Esc` a qualquer momento, inclusive para clicar.

## O que foi verificado

| Item | Como | Resultado |
|---|---|---|
| Contraste dos painéis | inspeção dos valores + capturas | ✅ |
| Fonte legível em 1280×720 | capturas `docs/img/*.png` | ✅ |
| Legenda PT sempre disponível | teste de input F1 | ✅ |
| Escolhas por teclado 1–4 | fluxo de diálogo + código | ✅ |
| Navegação por teclado no relatório | `grab_focus` + `R`/Enter | ✅ |
| Medidor não coberto | captura de objetivo | ✅ |
| Sem tempo limite | regra de design + teste de pausa | ✅ |

## Limitações conhecidas

- **Sem leitor de tela** (NVDA/TalkBack): a UI não expõe rótulos ARIA nem navegação
  por foco completa; é um trabalho futuro.
- **Sem escala de fonte configurável** no jogo; o zoom do navegador afeta a página, não
  o canvas.
- **Sem alto contraste alternativo** para daltônicos; o estado usa texto além de cor,
  mas o verde/vermelho do medidor não tem padrão alternativo.
- **Sem legendas em vídeo** do próprio jogo (o vídeo de entrega terá legendas queimadas).
- Não foi feito teste com usuários com deficiência; as conclusões são de inspeção.

## Próximos passos

1. Adicionar tema de alto contraste (fundo preto, texto amarelo).
2. Escala de fonte 100/125/150% no menu de opções.
3. Rótulos de acessibilidade nos botões e ordem de foco explícita.
4. Legendas/transcrição do vídeo de entrega.
