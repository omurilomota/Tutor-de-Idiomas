# Créditos de assets

> Toda asset externa precisa entrar aqui **antes** do merge, com autor, licença e link.
> Política completa em `docs/07-ASSETS-E-LICENCAS.md`.

## Modelos 3D

| Asset | Autor | Licença | Link | Onde é usado |
|---|---|---|---|---|
| Sala, móveis, TV, lâmpada, ar-condicionado e carregador | Equipe Home Switch (geometria procedural low-poly, gerada no próprio projeto) | CC0 / domínio público | — | `cenas/salas/SalaEstar.tscn` |
| Player (cápsula + câmera) | Equipe Home Switch | CC0 / domínio público | — | `cenas/player/Player.tscn` |
| Ícone do projeto (`icon.svg`) | Equipe Home Switch | CC0 | — | `project.godot` |

**Nenhum modelo de terceiros foi baixado.** A geometria usa `BoxMesh`, `CylinderMesh`,
`SphereMesh`, `PlaneMesh` e `QuadMesh` do próprio Godot, com materiais `StandardMaterial3D`
criados no projeto. Triângulos: poucos milhares (orçamento do GDD: <50k).

## Texturas

| Asset | Autor | Licença | Link | Onde é usado |
|---|---|---|---|---|
| _(nenhuma textura externa)_ | — | — | — | materiais com cor sólida |

## Áudio

| Asset | Autor | Licença | Link | Onde é usado |
|---|---|---|---|---|
| _(sem áudio no MVP — stretch)_ | — | — | — | — |

## Fontes

| Fonte | Autor | Licença | Link | Onde é usado |
|---|---|---|---|---|
| Fonte padrão do Godot (Noto Sans) | Google / Godot Engine | SIL Open Font License 1.1 (OFL) | https://godotengine.org | toda a UI |
| Emoji do relógio/ícones no README | — | — | — | documentação (não é asset do jogo) |

## Ferramentas

| Ferramenta | Licença | Uso |
|---|---|---|
| Godot Engine 4.6.3 | MIT | engine, export, testes headless |
| Mesa/llvmpipe | MIT | medição de FPS em software |
| ffmpeg | LGPL/GPL | geração do GIF a partir de capturas reais |

## Regras

1. **CC0 preferencial.** Pode ir para o repositório público sem complicação.
2. **CC-BY** é aceito com crédito visível no README e nesta tabela.
3. **Proibido** asset "grátis" sem licença explícita (ex.: Sketchfab sem licença declarada).
4. Guarde o comprovante em `assets/LICENCAS/<nome>-licenca.txt`.
