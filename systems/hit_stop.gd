extends Node

var hit_stop_active := false


func freeze(duration: float, time_scale: float = 0.05) -> void:
	if hit_stop_active:
		return

	hit_stop_active = true

	var previous_time_scale := Engine.time_scale
	Engine.time_scale = time_scale

	await get_tree().create_timer(
		duration,
		true,
		false,
		true
	).timeout

	Engine.time_scale = previous_time_scale
	hit_stop_active = false
