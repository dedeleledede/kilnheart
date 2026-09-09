extends Node

@export_group("References")
@export var melee_path := NodePath("../MeleeHitbox")
@export var visual_path := NodePath("../MeshInstance3D")

@export_group("Attack Motion")
@export var swing_degrees := 22.0
@export var swing_duration := 0.10
@export var return_duration := 0.13

@export_group("Hit Feedback")
@export var hit_stop_duration := 0.055
@export var hit_stop_scale := 0.10
@export var forward_hit_impulse := 13.5

@onready var melee := get_node(melee_path)
@onready var visual: Node3D = get_node(visual_path)

var base_rotation: Vector3
var base_scale: Vector3

var attack_tween: Tween


func _ready() -> void:
	base_rotation = visual.rotation
	base_scale = visual.scale

	melee.connect(
		"attack_started",
		on_attack_started
	)

	melee.connect(
		"attack_connected",
		on_attack_connected
	)

	melee.connect(
		"combo_finished",
		on_combo_finished
	)


func on_attack_started(combo_step: int) -> void:
	play_attack_motion(combo_step)


func play_attack_motion(combo_step: int) -> void:
	if attack_tween != null:
		attack_tween.kill()

	var swing_direction := 1.0

	if combo_step % 2 == 0:
		swing_direction = -1.0

	var windup_rotation := base_rotation
	windup_rotation.z -= deg_to_rad(
		swing_degrees * swing_direction
	)

	var strike_rotation := base_rotation
	strike_rotation.z += deg_to_rad(
		swing_degrees * swing_direction
	)

	visual.rotation = windup_rotation
	visual.scale = (
		base_scale
		* Vector3(0.90, 1.05, 1.10)
	)

	attack_tween = create_tween()
	attack_tween.set_process_mode(
		Tween.TWEEN_PROCESS_PHYSICS
	)
	attack_tween.set_trans(Tween.TRANS_QUAD)
	attack_tween.set_ease(Tween.EASE_OUT)

	attack_tween.tween_property(
		visual,
		"rotation",
		strike_rotation,
		swing_duration
	)

	attack_tween.parallel().tween_property(
		visual,
		"scale",
		base_scale * Vector3(1.05, 0.95, 1.15),
		swing_duration
	)

	attack_tween.tween_property(
		visual,
		"rotation",
		base_rotation,
		return_duration
	)

	attack_tween.parallel().tween_property(
		visual,
		"scale",
		base_scale,
		return_duration
	)


func on_attack_connected(
	_combo_step: int,
	_target: Area3D
) -> void:
	apply_hit_stop()
	apply_forward_impulse()


func apply_hit_stop() -> void:
	var hit_stop := get_node_or_null(
		"/root/HitStop"
	)

	if hit_stop == null:
		return

	hit_stop.call(
		"freeze",
		hit_stop_duration,
		hit_stop_scale
	)


func apply_forward_impulse() -> void:
	var player := get_parent()

	if player.has_method("apply_attack_impulse"):
		player.call(
			"apply_attack_impulse",
			forward_hit_impulse
		)


func on_combo_finished() -> void:
	if attack_tween != null:
		attack_tween.kill()

	visual.rotation = base_rotation
	visual.scale = base_scale
