extends RefCounted
## Barramento de eventos no estilo MQTT para a camada de IoT SIMULADA.
## Não é MQTT real: publica tópicos em memória para o HUD e para os testes.

signal published(topic: String, payload: Dictionary)

const MAX_HISTORY := 200

var history: Array = []


func topic_for(room: String, device_id: String, suffix: String = "state") -> String:
	return "home/%s/%s/%s" % [room, device_id, suffix]


func publish(topic: String, payload: Dictionary) -> void:
	history.append({
		"topic": topic,
		"payload": payload.duplicate(true),
		"timestamp_ms": Time.get_ticks_msec(),
	})
	if history.size() > MAX_HISTORY:
		history.pop_front()
	published.emit(topic, payload)


func last_message_for(device_id: String) -> Dictionary:
	for index in range(history.size() - 1, -1, -1):
		var topic := str(history[index].get("topic", ""))
		if topic.ends_with("/%s/state" % device_id):
			return history[index]
	return {}
