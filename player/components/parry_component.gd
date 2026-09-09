extends Area3D

@export var active_duration := 0.18
@export var cooldown_duration := 0.45
@export var hit_stop_duration := 0.19
@export var hit_stop_scale := 0.05

var active_time_left := 0.0
var cooldown_time_left := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 << 4

	monitoring = true
	monitorable = true

	area_entered.connect(on_area_entered)


func _physics_process(delta: float) -> void:
	cooldown_time_left = max(
		cooldown_time_left - delta,
		0.0
	)

	active_time_left = max(
		active_time_left - delta,
		0.0
	)

	if (
		Input.is_action_just_pressed("parry")
		and cooldown_time_left <= 0.0
	):
		begin_parry()


func begin_parry() -> void:
	active_time_left = active_duration
	cooldown_time_left = cooldown_duration

	for area in get_overlapping_areas():
		try_parry(area)


func on_area_entered(area: Area3D) -> void:
	try_parry(area)


func try_parry(area: Area3D) -> void:
	if active_time_left <= 0.0:
		return

	if not area.has_method("parry"):
		return

	var successful = area.call("parry")

	if successful != true:
		return

	print("PARRY SUCCESS")

	var hit_stop := get_node_or_null("/root/HitStop")

	if hit_stop != null:
		hit_stop.call(
			"freeze",
			hit_stop_duration,
			hit_stop_scale
		)
