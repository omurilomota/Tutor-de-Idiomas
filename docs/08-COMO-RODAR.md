# 08 — Como rodar

## Requisitos

- Godot **4.6.3** (a versão importa: export templates são versionados).
- Git.
- (Opcional) Python 3 para servir o build web localmente.

## Instalar o Godot

### Opção A — binário oficial (recomendada para CI e export)

```bash
mkdir -p ~/Applications ~/.local/bin
cd ~/Applications
wget https://github.com/godotengine/godot/releases/download/4.6.3-stable/Godot_v4.6.3-stable_linux.x86_64.zip
unzip Godot_v4.6.3-stable_linux.x86_64.zip
chmod +x Godot_v4.6.3-stable_linux.x86_64
ln -sf ~/Applications/Godot_v4.6.3-stable_linux.x86_64 ~/.local/bin/godot
godot --version   # 4.6.3.stable.official
```

### Opção B — Flatpak

```bash
flatpak install flathub org.godotengine.Godot
flatpak run org.godotengine.Godot --path .
```

No Flatpak, os templates ficam em:

```
~/.var/app/org.godotengine.Godot/data/godot/export_templates/4.6.3.stable/
```

## Abrir o projeto

```bash
cd Tutor-de-Idiomas
godot --path .
```

Ou abra o Godot, clique em **Import** e selecione `project.godot`.

## Rodar os testes

```bash
godot --headless --path . --import          # primeira vez / após puxar assets
godot --headless --path . --script testes/run_tests.gd
```

Saída esperada:

```
== Home Switch — testes ==
Verificações: 30 | Falhas: 0
OK
```

O runner retorna código 1 em falha — é isso que quebra o CI.

## Exportar para web

### 1. Instalar export templates

Baixe `Godot_v4.6.3-stable_export_templates.tpz` no mesmo release e extraia em:

```
~/.local/share/godot/export_templates/4.6.3.stable/
```

Verifique se a pasta tem `web_release.zip` (e os demais templates).

### 2. Exportar

```bash
mkdir -p build/web
godot --headless --path . --export-release "Web" build/web/index.html
```

### 3. Servir localmente

```bash
cd build/web
python3 -m http.server 8000
# abra http://localhost:8000
```

Abrir `index.html` com `file://` **não funciona** (o jogo precisa de HTTP).

### 4. Publicar no GitHub Pages

O workflow `.github/workflows/export-web.yml` publica automaticamente em tags `v*`.

Configuração única no GitHub:

1. **Settings → Pages → Source: GitHub Actions**.
2. Rode o workflow manualmente em **Actions → Export Web → Run workflow**.

## Exportar para desktop

Crie presets no editor (**Project → Export**) para Linux e Windows, instale os templates
e use:

```bash
godot --headless --path . --export-release "Linux" build/linux/home-switch.x86_64
```

Não commitar builds: `build/` está no `.gitignore`.

## CI (GitHub Actions)

| Workflow | Quando roda | O que faz |
|---|---|---|
| `ci.yml` | push em `main`/`dev` e PRs | importa o projeto, roda testes e valida JSONs |
| `export-web.yml` | tag `v*` ou manual | exporta web e publica no Pages |

## Problemas comuns

| Sintoma | Causa | Solução |
|---|---|---|
| `No export template found` | templates ausentes/versão errada | instalar em `4.6.3.stable` e conferir `godot --version` |
| Página web em branco | aberta via `file://` | servir com `python3 -m http.server` |
| Erro de `SharedArrayBuffer` | export com threads | manter `variant/thread_support=false` |
| `Cannot open file res://...` | projeto importado em outra máquina | apagar `.godot/` e rodar `--import` |
| Cena quebrada após merge | conflito de `.tscn` | abortar merge, avisar o dono da cena |
| Input não responde | layout de teclado / Input Map | testar com `physical_keycode`; conferir Project Settings → Input Map |
| FPS baixo | sombras/AA/escala | conferir `project.godot`; reduzir `scaling_3d/scale` |
| Flatpak não vê o projeto | permissão de pasta | usar binário oficial ou `flatpak override --filesystem=home` |
| Deploy de tag falha | política do ambiente `github-pages` só permite `main` | adicionar política de tag `v*` em Settings → Environments → github-pages |

## Configuração do GitHub (uma vez)

### Colaboradores

```bash
gh api -X PUT repos/omurilomota/Tutor-de-Idiomas/collaborators/USER -f permission=push
```

### Proteção da `main`

**Settings → Branches → Add branch protection rule**:

- [x] Require a pull request before merging
- [x] Require approvals: 1
- [x] Dismiss stale approvals
- [x] Require status checks: `testes`
- [x] Require conversation resolution

### CODEOWNERS

Editar `.github/CODEOWNERS` com os usuários reais e ativar
**Settings → Code security → Code owners review**.

### Pages

**Settings → Pages → Source: GitHub Actions**.

## Checklist de onboarding (novo membro)

- [ ] Instalou Godot 4.6.3.
- [ ] Clonou o repositório.
- [ ] Rodou `--import` e os testes (30 OK).
- [ ] Leu `docs/02-ARQUITETURA.md` e `docs/06-DIVISAO-TRABALHO.md`.
- [ ] Criou a branch `feat/<area>-<nome>`.
- [ ] Abriu o primeiro PR pequeno.
