# 06 — Divisão de trabalho

## Donos por área

| Área | Dono | Pastas/arquivos | Entregáveis |
|---|---|---|---|
| Cenas e arte 3D | **Gian** | `cenas/`, `assets/`, `project.godot`, `export_presets.cfg` | sala jogável, 4 props, player, UI visual, iluminação, performance, build web |
| Diálogos e lógica | **Matheus** | `dialogos/`, `scripts/dialogos/`, `scripts/player/`, `scripts/ui/dialogo/` | loader/validador, caixa de diálogo, árvores, vocabulário, objetivos |
| Energia, dados e qualidade | **Terceiro** | `scripts/energia/`, `dados/`, `testes/`, `.github/`, `scripts/ui/hud/` | simulação, baseline, relatório, HUD, CI, testes, docs, vídeo |
| Coordenação e documentação | **Murilo** | `docs/`, `README.md`, issues | escopo, cronograma, relatório da banca, organização |

> Substituir “Terceiro” pelo nome real assim que definido.

## Regra de ouro: um dono por arquivo

| Arquivo | Dono | Outros podem |
|---|---|---|
| `cenas/**/*.tscn` | Gian | ler, pedir mudança via issue |
| `assets/**` | Gian | usar em scripts |
| `dialogos/*.json` | Matheus | sugerir texto em issue |
| `scripts/dialogos/`, `scripts/player/`, `scripts/ui/dialogo/` | Matheus | revisar |
| `scripts/energia/`, `scripts/ui/hud/`, `dados/` | Terceiro | revisar |
| `testes/`, `.github/` | Terceiro | rodar localmente |
| `project.godot` | Gian | pedir alteração (autoload/input map) |
| `docs/` | Murilo | corrigir typo via PR |

**Nunca** duas pessoas editam o mesmo `.tscn` ao mesmo tempo. Se precisar de um nó novo,
o dono da cena adiciona e expõe com `%NomeUnico`.

## Branches

```
main        entrega estável (protegida)
 └─ dev     integração contínua
     ├─ feat/<area>-<descricao>     ex.: feat/energia-medidor
     ├─ art/<descricao>             ex.: art/sala-lowpoly
     ├─ fix/<descricao>             ex.: fix/dialogo-travado
     └─ docs/<descricao>            ex.: docs/relatorio-banca
```

- Nunca commitar direto em `main`.
- `dev` recebe PRs de feature; `main` recebe PR de `dev` no fim de cada fase.
- Merge por **squash**; apagar a branch depois.
- PR pequeno: <400 linhas alteradas, 1 assunto.

## Commits

Padrão [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: adiciona objetivo de desligar a TV
fix: corrige ciclo do ar-condicionado no modo eco
art: modela sala de estar low-poly
docs: atualiza tabela de dispositivos
test: cobre baseline da TV
chore: configura CI
```

Mensagem no imperativo, em português, curta.

## Pull Request

Checklist do template:

- [ ] Escopo do PR explicado em 2 linhas.
- [ ] Rodei os testes localmente (`run_tests.gd`).
- [ ] Não editei arquivo de outra pessoa.
- [ ] Se mexi em cena, avisei o dono.
- [ ] Se adicionei asset, registrei a licença.
- [ ] Atualizei a doc afetada.

Revisão em até 24 h. Quem revisa: pelo menos 1 pessoa que não escreveu o código.

## Rituais

| Ritual | Quando | Pauta |
|---|---|---|
| Sync semanal | segunda, 30 min | o que passou no gate, 3 prioridades, bloqueios |
| Check-in diário | assíncrono | feito / próximo / bloqueio |
| Playtest de fase | fim de fase | 15 min jogando + 3 bugs + 1 ajuste |
| Retro curta | fim de fase | manter / mudar / parar |

## Matriz RACI (simplificada)

| Entrega | Responsável | Aprovador | Consultado |
|---|---|---|---|
| Sala 3D | Gian | Murilo | Matheus (colisões) |
| Sistema de diálogo | Matheus | Murilo | Gian (UI) |
| Energia e relatório | Terceiro | Murilo | Matheus (objetivos) |
| Build e deploy | Gian | Terceiro | — |
| Documentação | Murilo | — | todos |
| Apresentação | todos | professor | — |

## Conflitos e decisões

- Decisão técnica que afeta mais de uma área → issue com label `decisao` e 24 h para comentar.
- Empate → o dono da área decide; se envolver `project.godot` ou escopo, Murilo desempata.
- Registro final em `docs/02-ARQUITETURA.md` (tabela “Decisões registradas”).

## Se alguém ficar bloqueado

1. Comente na issue em até 1 h.
2. Se for dependência de cena, abra issue para o dono com print do erro.
3. Se for ambiente (Godot, export), siga `docs/08-COMO-RODAR.md`; se persistir, poste o log completo.
