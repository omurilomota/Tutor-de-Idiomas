# Home Switch 🏠🇬🇧

**Serious game 3D para aprender inglês reduzindo o consumo de energia de casa.**

Você é o novo colega de quarto do Alex. Ele fala inglês, pede ajuda com a casa e só
continua a conversa quando você **faz** o que ele pediu: apagar a luz, desligar a TV,
colocar o ar-condicionado no modo eco. Cada ação muda o medidor de energia em tempo real
e rende uma palavra nova no vocabulário.

> **Status:** Fase 0 concluída — projeto Godot, CI, testes e build web funcionando.
> O vertical slice jogável começa na Fase 1.

[![CI](https://github.com/omurilomota/Tutor-de-Idiomas/actions/workflows/ci.yml/badge.svg)](https://github.com/omurilomota/Tutor-de-Idiomas/actions/workflows/ci.yml)
[![Godot](https://img.shields.io/badge/Godot-4.6-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Licença](https://img.shields.io/badge/c%C3%B3digo-MIT-green)](LICENSE)

---

## O que já funciona

- Projeto Godot 4.6.3 com renderer **Compatibility (GLES3)**, pensado para PC fraco.
- Simulação de energia com 4 dispositivos e baseline calculado pela mesma fórmula.
- Árvore de diálogo do MVP (`dialogos/sala_01.json`) com 3 objetivos físicos.
- Validador de diálogos + testes headless (28 verificações) no CI.
- Build web sem threads, publicado no GitHub Pages.

## Stack

| Camada | Tecnologia |
|---|---|
| Engine | Godot 4.6.3 (Compatibility / GLES3) |
| Lógica | GDScript |
| Conteúdo | JSON (diálogos, dispositivos, configuração) |
| Testes | Runner headless próprio + GitHub Actions |
| Deploy | GitHub Pages (export Web) |

## Como rodar

```bash
# 1. Instale o Godot 4.6.3 (binário oficial ou Flatpak)
#    https://godotengine.org/download

# 2. Abra o projeto
godot --path .

# 3. Rode os testes
godot --headless --path . --import
godot --headless --path . --script testes/run_tests.gd

# 4. Gere o build web
godot --headless --path . --export-release "Web" build/web/index.html
```

Detalhes de instalação, export e problemas comuns: [`docs/08-COMO-RODAR.md`](docs/08-COMO-RODAR.md).

## Controles (a partir da Fase 1)

| Tecla | Ação |
|---|---|
| `W A S D` | andar |
| Mouse | olhar |
| `E` | interagir / avançar diálogo |
| `1`–`4` | escolher resposta |
| `F1` | alternar legenda (EN+PT / EN / PT) |
| `Esc` | liberar o mouse |

## Estrutura

```
cenas/      cenas 3D e UI (Gian)
assets/     modelos, texturas, áudio e licenças (Gian)
dialogos/   árvores de diálogo em JSON (Matheus)
dados/      dispositivos, tarifa e baseline (Terceiro)
scripts/    autoloads, diálogo, energia, player e UI
testes/     runner headless + testes
docs/       escopo, GDD, arquitetura, energia, cronograma
```

## Documentação

| Documento | Assunto |
|---|---|
| [00 — Escopo](docs/00-ESCOPO.md) | problema, objetivos, dentro/fora, critérios de aceite |
| [01 — GDD](docs/01-GDD.md) | loop, sala, dispositivos, NPC, progressão |
| [02 — Arquitetura](docs/02-ARQUITETURA.md) | autoloads, sinais, contrato de cenas |
| [03 — Diálogos](docs/03-DIALOGOS.md) | formato JSON e como escrever sem programar |
| [04 — Energia](docs/04-ENERGIA.md) | fórmulas, baseline, relatório |
| [05 — Cronograma](docs/05-CRONOGRAMA.md) | fases, gates e riscos |
| [06 — Divisão de trabalho](docs/06-DIVISAO-TRABALHO.md) | donos, branches, rituais |
| [07 — Assets e licenças](docs/07-ASSETS-E-LICENCAS.md) | política CC0 e créditos |
| [08 — Como rodar](docs/08-COMO-RODAR.md) | instalação, export, CI |
| [09 — Relatório da banca](docs/09-RELATORIO-BANCA.md) | temas, decisões, limitações |

## Equipe

| Pessoa | Área |
|---|---|
| Gian | cenas 3D, arte e performance |
| Matheus | diálogos, GDScript e player |
| Terceiro membro | energia, HUD, testes/CI e documentação |

## Licenças

Código sob **MIT** ([LICENSE](LICENSE)). Assets externos são CC0 ou CC-BY, com crédito
individual em [`assets/LICENCAS/CREDITOS.md`](assets/LICENCAS/CREDITOS.md).
