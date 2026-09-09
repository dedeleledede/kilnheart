extends Node

@export_group("References")
@export var visual_path := NodePath("../MeshInstance3D")

@export_group("Damage")
@export var flash_color := Color(1.0, 0.85, 0.65)
@export var flash_intensity := 2.5
@export var damage_recovery_duration := 0.12

@export_group("Death")
@export var death_duration := 0.20
@export var death_rotation_degrees := 35.0

@onready var health_component := get_node(
	"../HealthComponent"
)

@onready var visual: MeshInstance3D = get_node(
	visual_path
)

var base_scale: Vector3
var base_rotation: Vector3

var flash_material: StandardMaterial3D
var feedback_tween: Tween

var dying := false


func _ready() -> void:
	base_scale = visual.scale
	base_rotation = visual.rotation

	create_flash_material()

	health_component.connect(
		"damaged",
		on_damaged
	)

	health_component.connect(
		"died",
		on_died
	)


func create_flash_material() -> void:
	flash_material = StandardMaterial3D.new()

	flash_material.shading_mode = (
		BaseMaterial3D.SHADING_MODE_UNSHADED
	)

	flash_material.albedo_color = flash_color
	flash_material.emission_enabled = true
	flash_material.emission = flash_color
	flash_material.emission_energy_multiplier = (
		flash_intensity
	)


func on_damaged(
	_damage: int,
	_current_health: int
) -> void:
	if dying:
		return

	stop_current_tween()

	visual.material_overlay = flash_material
	visual.scale = (
		base_scale
		* Vector3(1.18, 0.82, 1.18)
	)

	feedback_tween = create_tween()
	feedback_tween.set_process_mode(
		Tween.TWEEN_PROCESS_PHYSICS
	)

	feedback_tween.set_trans(Tween.TRANS_BACK)
	feedback_tween.set_ease(Tween.EASE_OUT)

	feedback_tween.tween_property(
		visual,
		"scale",
		base_scale,
		damage_recovery_duration
	)

	feedback_tween.tween_callback(
		clear_flash
	)


func on_died() -> void:
	dying = true

	stop_current_tween()

	visual.material_overlay = flash_material

	var death_rotation := base_rotation
	death_rotation.z += deg_to_rad(
		death_rotation_degrees
	)

	feedback_tween = create_tween()
	feedback_tween.set_process_mode(
		Tween.TWEEN_PROCESS_PHYSICS
	)

	feedback_tween.set_trans(Tween.TRANS_BACK)
	feedback_tween.set_ease(Tween.EASE_IN)

	feedback_tween.tween_property(
		visual,
		"scale",
		Vector3.ZERO,
		death_duration
	)

	feedback_tween.parallel().tween_property(
		visual,
		"rotation",
		death_rotation,
		death_duration
	)


func clear_flash() -> void:
	if dying:
		return

	visual.material_overlay = null


func stop_current_tween() -> void:
	if feedback_tween != null:
		feedback_tween.kill()
