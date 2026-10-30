# 12 — Roteiro do vídeo (3 minutos)

> **Status:** roteiro pronto; gravação/edição ainda não realizadas (dependem de voz e
> edição humanas). O vídeo deve ser publicado como “não listado” no YouTube e linkado
> no README.

## Formato

- 1280×720, 30 fps, H.264/AAC.
- 3:00 ±15 s, com legendas queimadas em português (acessibilidade).
- Áudio: narração limpa + som do jogo em volume baixo (se houver).
- Sem música com copyright; se usar, CC0 e creditada.

## Shot list

| Tempo | Imagem | Narração (PT) |
|---|---|---|
| 0:00–0:15 | Tela título + GIF do objetivo | “Aprender inglês costuma ficar no caderno. O consumo de energia, na conta. O Home Switch junta os dois.” |
| 0:15–0:35 | `docs/img/inicio.png` / gameplay parado | “Você é o novo colega de quarto do Alex. Ele fala inglês e pede ajuda com a casa.” |
| 0:35–1:00 | Gameplay: intro, escolha “Hi!”, pedido da luz | “O diálogo só avança quando você executa o pedido. Aqui, apagar a luz.” |
| 1:00–1:25 | Andar até a lâmpada, prompt EN/PT, apertar E | “O prompt é bilíngue. Aperte E perto do aparelho.” |
| 1:25–1:45 | Medidor caindo + cartão “turn off the light” | “O medidor reage em tempo real e a palavra nova entra no glossário.” |
| 1:45–2:10 | Desligar a TV e colocar o ar no eco | “Agora a TV e o ar-condicionado. Cada escolha muda kW, kWh, R$ e CO₂.” |
| 2:10–2:35 | F4 → tela de relatório | “No fim do dia, o relatório compara com um baseline calculado: 64,6% de economia, nota A.” |
| 2:35–2:50 | Slide de arquitetura ou diagrama | “Quatro autoloads, conteúdo em JSON validado e testes headless no CI.” |
| 2:50–3:00 | Logo + link do Pages | “Home Switch. Jogue no navegador. Obrigado!” |

## Como gravar (OBS ou similar)

1. Configurar cena 1280×720, 30 fps, captura de janela do Godot.
2. Abrir o jogo, `Esc` libera o mouse; começar com o diálogo inicial.
3. Seguir o roteiro; usar `F1` para mostrar a legenda EN+PT uma vez.
4. No minuto 2:10, apertar `F4` para encerrar o dia na hora.
5. Gravar a narração em uma segunda passada (mais fácil de corrigir).
6. Editar no Kdenlive/DaVinci; queimar legendas PT; exportar H.264.
7. Publicar como “não listado” e colar o link no README e na release.

## Comandos úteis

```bash
# capturar quadros reais (GIF/print) em um display virtual
xvfb-run -a -s "-screen 0 1280x720x24" godot --path . \
  --audio-driver Dummy --script tools/benchmark_fps.gd

# servidor local do build web
cd build/web && python3 -m http.server 8000

# GIF a partir de uma sequência de quadros
ffmpeg -framerate 10 -i frame_%04d.png \
  -vf "scale=960:-1,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 docs/img/gameplay.gif
```

## Checklist antes de publicar

- [ ] Duração entre 2:45 e 3:15.
- [ ] Narração audível e sem ruído.
- [ ] Legendas em PT conferidas.
- [ ] Link do jogo aparece no fim e na descrição.
- [ ] Sem dados pessoais, notificações ou abas abertas.
- [ ] Vídeo assistido do começo ao fim em 720p e 360p.
