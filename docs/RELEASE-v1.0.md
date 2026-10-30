# Home Switch v1.0 — notas da release

**Data:** 24/10/2026 · **Engine:** Godot 4.6.3 (Compatibility / GLES3) · **Licença:** MIT

> **Estado:** artefatos gerados e verificados localmente. A tag `v1.0`, o push e a
> publicação no GitHub Pages/release ainda dependem de autorização do mantenedor.

## O que entra na v1.0

- Sala de estar 3D low-poly, primeira pessoa, 4 dispositivos interativos.
- 4 diálogos encadeados, 9 objetivos físicos e 32 palavras/frases no glossário.
- HUD ao vivo, relatório final com baseline calculado, nota A–D e reinício.
- Acessibilidade: legenda EN+PT/EN/PT, sem cronômetro, contraste AA/AAA, teclado.
- 227 verificações automatizadas e benchmark de 90–100 FPS em software (llvmpipe).
- Builds Web, Linux x86_64 e Windows x86_64.

## Downloads e checksums

| Arquivo | Tamanho | SHA-256 |
|---|---|---|
| `home-switch.x86_64` (Linux) | 68 MB | `730133b790afd88f79adc1fb476c0f233486fc2f8b11d485da6a71d659aa53b9` |
| `home-switch.exe` (Windows) | 100 MB | `fe9fd96dc3dbd756c7ceb82004a2a11e5824445d27b0af0345a15a28f7a99d2a` |
| `index.wasm` (Web) | 36 MB | `26b61ce95247012ab3dca3ff51e96d1cdbff44ee91a8c20a83e150afca83f1b6` |
| `index.pck` (Web) | 118 KB | `87608478b9dd9e49f63ce3a17ff7d4addb8afb7b1405aa3b707279af794cdacf` |
| `index.js` (Web) | 308 KB | `e3f56ee40e6f84371053db06692cfac15e2c8659547b11c6b2dfa1996dabd981` |

O build web completo precisa de `index.html`, `index.js`, `index.wasm`, `index.pck`,
`index.audio.*.worklet.js` e os PNGs de ícone; o pacote inteiro está em `build/web/`.

## Como jogar

- **Navegador:** abra o link do GitHub Pages (ou sirva `build/web` com HTTP).
- **Linux:** `chmod +x home-switch.x86_64 && ./home-switch.x86_64`
- **Windows:** execute `home-switch.exe` (SmartScreen pode avisar por não haver assinatura).
- Controles: WASD + mouse, `E`, `1–4`, `F1`, `F3`, `F4`, `Esc`/clique.

## Verificação feita

| Item | Resultado |
|---|---|
| `godot --headless --path . --script testes/run_tests.gd` | 227 verificações, 0 falhas |
| Export Web/Linux/Windows | concluído (Godot 4.6.3) |
| Build web em Chrome (WebGL 2.0, SwiftShader) | abre, roda e captura o mouse após clique |
| Build web em Firefox 155 (Playwright, WebGL 2.0) | abre, canvas 1280×720, 0 erros de console |
| Binário Linux exportado | inicia e roda 120 frames headless sem erro |
| Performance | 96,3 FPS a 1280×720 em llvmpipe (software), 300 frames (faixa 90–100) |
| Relatório | 22,05 kWh baseline → 7,812 kWh / 64,6% / nota A |

## Bug corrigido que vale registrar

No reinício, o `EnergyManager` recarregava o JSON e criava novos objetos de dispositivo.
Os nós 3D continuavam apontando para os antigos, então o prompt e o brilho da lâmpada
ficavam presos no estado anterior. A correção (`EnergyDevice.reset()` + reset no lugar)
está documentada em `docs/02-ARQUITETURA.md` e coberta por `testes/test_partida.gd`.

## Problemas conhecidos

- Sem áudio, voz ou TTS.
- Sem save/load; reiniciar recomeça a partida.
- Sem teste com usuários reais (Firefox e Chrome testados só em headless).
- Baseline, tarifa e CO₂ são didáticos, não medições reais.
- Windows sem assinatura digital (SmartScreen).

## Checklist de publicação (pendente)

- [ ] Revisar o diff e rodar os 227 testes uma última vez.
- [ ] Fazer merge de `dev` em `main` via PR.
- [ ] `git tag -a v1.0 -m "Home Switch v1.0"` e `git push origin v1.0`.
- [ ] Conferir o workflow `Export Web` verde e o Pages abrindo.
- [ ] Criar a release `v1.0` e anexar Linux, Windows e o ZIP do build web.
- [ ] Publicar o vídeo de 3 min e colar o link no README.
- [ ] Ensaiar a demo de 5 min em outra máquina.
