extends Area3D

signal attack_started(combo_step: int)
signal attack_connected(combo_step: int, target: Area3D)
signal combo_finished

@export_group("Combo Timings")
@export var attack_durations := PackedFloat32Array([
	0.28,
	0.30,
	0.42
])

@export var active_window_starts := PackedFloat32Array([
	0.06,
	0.07,
	0.10
])

@export var active_window_ends := PackedFloat32Array([
	0.15,
	0.17,
	0.28
])

@export_group("Damage")
@export var attack_damages := PackedInt32Array([
	1,
	1,
	2
])

var attacking := false
var next_attack_queued := false

var combo_step := -1
var attack_time := 0.0
var attack_count := 0

var hit_targets: Dictionary = {}


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 << 2

	monitoring = true
	monitorable = false

	if not has_valid_attack_data():
		push_error(
			"MeleeComponent: os arrays de ataque precisam ter o mesmo tamanho."
		)
		set_physics_process(false)
		return

	attack_count = attack_durations.size()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		handle_attack_input()

	if not attacking:
		return

	attack_time += delta

	var active_start := active_window_starts[combo_step]
	var active_end := active_window_ends[combo_step]

	if (
		attack_time >= active_start
		and attack_time <= active_end
	):
		check_attack_hits()

	if attack_time >= attack_durations[combo_step]:
		finish_current_attack()


func handle_attack_input() -> void:
	if not attacking:
		start_attack(0)
		return

	if combo_step < attack_count - 1:
		next_attack_queued = true


func start_attack(new_combo_step: int) -> void:
	attacking = true
	next_attack_queued = false

	combo_step = new_combo_step
	attack_time = 0.0

	hit_targets.clear()

	print("ATTACK ", combo_step + 1)
	attack_started.emit(combo_step)


func check_attack_hits() -> void:
	for area in get_overlapping_areas():
		var target_id := area.get_instance_id()

		if hit_targets.has(target_id):
			continue

		if not area.has_method("receive_melee_attack"):
			continue

		hit_targets[target_id] = true

		area.call(
			"receive_melee_attack",
			attack_damages[combo_step],
			global_position
		)

		attack_connected.emit(combo_step, area)


func finish_current_attack() -> void:
	if (
		next_attack_queued
		and combo_step < attack_count - 1
	):
		start_attack(combo_step + 1)
		return

	attacking = false
	next_attack_queued = false
	combo_step = -1
	attack_time = 0.0

	hit_targets.clear()
	combo_finished.emit()


func has_valid_attack_data() -> bool:
	var count := attack_durations.size()

	return (
		count > 0
		and active_window_starts.size() == count
		and active_window_ends.size() == count
		and attack_damages.size() == count
	)
