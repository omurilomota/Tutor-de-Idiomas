# 07 — Assets e licenças

## Política

| Licença | Permitido? | Como registrar |
|---|---|---|
| **CC0 / domínio público** | Sim, preferencial | linha na tabela + arquivo em `assets/LICENCAS/` |
| **CC-BY** | Sim, com crédito | crédito no README e na tabela |
| **CC-BY-SA** | Evitar | contamina o projeto; só com aprovação |
| **Uso pessoal / sem licença** | **Não** | descartar |
| **Asset pago** | Não no MVP | sem orçamento |

Regras adicionais:

1. Nenhum asset entra no repositório sem licença comprovada.
2. Guardar o print/arquivo da licença em `assets/LICENCAS/<nome>-licenca.txt`.
3. Modelos `.blend` não entram no repo; exportar `.glb`.
4. Arquivo individual >10 MB: abrir issue antes (LFS ou substituição).
5. Áudio e fonte seguem a mesma política.

## Fontes confiáveis

| Site | Licença típica | Observação |
|---|---|---|
| [Kenney](https://kenney.nl/assets) | CC0 | kits de móveis, eletrodomésticos, UI |
| [Quaternius](https://quaternius.com) | CC0 | packs low-poly de casa |
| [Poly Pizza](https://poly.pizza) | CC0/CC-BY (varia) | conferir item a item |
| [Sketchfab](https://sketchfab.com) | varia | **só** com licença explícita CC0/CC-BY |
| [Freesound](https://freesound.org) | CC0/CC-BY | conferir cada som |
| [Google Fonts](https://fonts.google.com) | OFL/Apache | manter o arquivo de licença |

## Tabela de assets

Preencher em [`assets/LICENCAS/CREDITOS.md`](../assets/LICENCAS/CREDITOS.md).
Resumo do que já está previsto:

| Categoria | Asset | Autor | Licença | Status |
|---|---|---|---|---|
| Modelos | sala + móveis + 4 aparelhos (procedural low-poly) | Equipe Home Switch | CC0 | ✅ feito |
| Fonte | fonte padrão do Godot (Noto Sans) | Godot/Google | OFL | ✅ embutida na engine |
| Áudio | cliques e ambiente | — | — | opcional, fora do MVP |

A decisão de fazer a geometria procedural foi tomada para não adicionar dependência
externa, manter o build leve e garantir licença. Os kits Kenney/Quaternius ficam como
opção de arte final; se entrarem, precisam ser registrados em `CREDITOS.md`.

## Checklist de importação

- [ ] Baixou de fonte confiável.
- [ ] Leu a licença e salvou o comprovante.
- [ ] Importou no Godot e verificou escala/orientação.
- [ ] Testou material no renderer Compatibility.
- [ ] Mediu o tamanho do arquivo (<10 MB).
- [ ] Registrou na tabela com URL e onde usa.
- [ ] Se CC-BY, adicionou o crédito no README.

## Como creditar (modelo)

```
"Furniture Kit" por Kenney — CC0 — https://kenney.nl/assets/furniture-kit
"Low Poly Appliances" por Quaternius — CC0 — https://quaternius.com
```

## O que **não** fazer

- Baixar modelo do Sketchfab sem licença e “dar os créditos depois”.
- Usar imagem do Google como textura.
- Copiar música de jogo comercial.
- Commitar asset de 50 MB “só para testar”.
