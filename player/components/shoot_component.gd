extends Node3D

signal shot_fired(projectile: Area3D)

@export var projectile_scene: PackedScene
@export var fire_interval := 0.32
@export var aim_assist_path := NodePath(
	"../../HUD/AimAssist"
)

@onready var muzzle: Marker3D = $Muzzle
@onready var aim_assist := get_node_or_null(
	aim_assist_path
)

var fire_cooldown_left := 0.0


func _physics_process(delta: float) -> void:
	fire_cooldown_left = max(
		fire_cooldown_left - delta,
		0.0
	)

	if (
		Input.is_action_pressed("shoot")
		and fire_cooldown_left <= 0.0
	):
		shoot()


func shoot() -> void:
	if projectile_scene == null:
		push_warning(
			"ShootComponent está sem projectile_scene."
		)
		return

	var projectile := (
		projectile_scene.instantiate()
		as Area3D
	)

	get_tree().current_scene.add_child(
		projectile
	)

	projectile.global_transform = (
		muzzle.global_transform
	)

	var shoot_direction := (
	-muzzle.global_transform.basis.z
	)

	if (
		aim_assist != null
		and aim_assist.has_method(
			"get_aim_direction"
		)
	):
		shoot_direction = aim_assist.call(
			"get_aim_direction",
			muzzle.global_position
		)

	projectile.call(
		"configure",
		shoot_direction
	)

	fire_cooldown_left = fire_interval

	shot_fired.emit(projectile)
