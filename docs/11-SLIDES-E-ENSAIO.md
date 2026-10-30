# 11 — Slides e ensaio (5 minutos)

## Estrutura do deck (9 slides)

| # | Título | Conteúdo (3–4 bullets) |
|---|---|---|
| 1 | **O problema** | inglês descontextualizado; energia invisível na conta; prática sem consequência |
| 2 | **A proposta** | Home Switch: FPS 3D, Alex pede em inglês, agir muda o medidor; 5–8 min |
| 3 | **Demo** | GIF/print do objetivo da luz; link do Pages; 3 objetivos em 2 min |
| 4 | **Loop** | ouvir → escolher → andar → apertar E → medidor reage → vocabulário |
| 5 | **Energia** | baseline 22,05 kWh; partida ótima 7,812 kWh = 64,6%; nota A–D; CO₂/R$ |
| 6 | **Arquitetura** | autoloads; diálogo JSON; `objective` bloqueia avanço; 4 devices na camada 2 |
| 7 | **Qualidade** | 227 testes; validador de diálogo; CI; ~96 FPS em software; build web/Linux/Windows |
| 8 | **Temas e limites** | IoT simulado; metaverso parcial; sem AR/VR; sem voz/LLM; baseline didático |
| 9 | **Próximos passos** | cozinha/banheiro; TTS; MQTT real; teste com usuários; obrigado + link |

### Regras visuais

- Fundo escuro `#0A0F14`, texto `#F5F7FA`, acento verde `#4FC98A`.
- Uma imagem por slide no máximo; usar as capturas de `docs/img/`.
- Fonte 24–32 px no corpo, 44–56 px em títulos.
- Nada de parágrafo: no máximo 12 palavras por bullet.

## Ensaio cronometrado (5:00)

| Tempo | Fala | Ação |
|---|---|---|
| 0:00–0:30 | “Aprender inglês fica no caderno; energia fica na conta. O Home Switch junta os dois.” | slide 1 |
| 0:30–1:00 | “Você é o novo colega de quarto do Alex. Ele pede em inglês e só continua quando você faz.” | slide 2 |
| 1:00–2:30 | “Vou apagar a luz, desligar a TV e colocar o ar no eco. Olhem o medidor e o vocabulário.” | jogo ao vivo (ou GIF) |
| 2:30–3:10 | “No fim, o relatório compara com um baseline calculado: 64,6% de economia, nota A.” | F4 + relatório |
| 3:10–4:00 | “A arquitetura separa conteúdo (JSON), simulação e cena. O diálogo não avança sem o evento físico.” | slide 6 |
| 4:00–4:40 | “227 testes, CI, build web e exports desktop; 90–100 FPS até em renderizador por software.” | slide 7 |
| 4:40–5:00 | “Limitações: sem voz, sem AR, IoT simulado. Próximo passo é testar com alunos. Obrigado!” | slide 9 |

**Marcos de segurança:** 1:00 (demo começa), 2:30 (relatório), 4:00 (qualidade), 5:00 (fim).

## Plano B (internet ou PC falhou)

1. **Build local Linux** em `build/linux/home-switch.x86_64` (offline).
2. **Build web local** servido com `python3 -m http.server 8000` em `build/web`.
3. **Vídeo de 3 min** já baixado no celular/notebook.
4. **GIF e prints** em `docs/img/` abrem sem internet.
5. Slides em PDF exportado, não só no Google Slides.

## Checklist do ensaio

- [ ] Cronometrar 3 vezes; a última ≤5:00.
- [ ] Testar o build em outra máquina (ou outro navegador).
- [ ] Testar `F4` e o reinício antes de apresentar.
- [ ] Desligar notificações e o screensaver.
- [ ] Levar cabo HDMI/USB-C e adaptador.
- [ ] Ter o vídeo e os slides em pendrive.
- [ ] Ensaiar a pergunta “isso é metaverso?” com a resposta honesta do doc 09.
