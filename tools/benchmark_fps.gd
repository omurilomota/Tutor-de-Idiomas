extends SceneTree
## Mede o FPS real do projeto (rode com display/Xvfb, sem --headless).
## Uso: godot --path . --script tools/benchmark_fps.gd
## Resultado de referência (llvmpipe, 1280×720): ~100 FPS.

var started := false

func _process(_delta: float) -> bool:
	if not started:
		started = true
		_run()
	return false

func _run() -> void:
	var main = (load("res://cenas/main/Main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	main.start_game()
	for i in 120:
		await process_frame

	var frames := 0
	var t0 := Time.get_ticks_usec()
	while frames < 300:
		await process_frame
		frames += 1
	var elapsed := (Time.get_ticks_usec() - t0) / 1_000_000.0
	print("BENCHMARK frames=", frames, " elapsed=", "%.3f" % elapsed, " fps=", "%.1f" % (frames / elapsed), " engine_fps=", Engine.get_frames_per_second())
	quit(0)
