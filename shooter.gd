extends Node3D

@export var projectile_scene: PackedScene
@export var fire_interval := 1.2
@export var attack_range := 45.0

@onready var player := get_node("../Player")

var fire_timer := 0.4


func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
		
	var distance_to_player := global_position.distance_to(
	player.global_position
)

	if distance_to_player > attack_range:
		return

	fire_timer -= delta

	if fire_timer <= 0.0:
		shoot()
		fire_timer = fire_interval


func shoot() -> void:
	var projectile = projectile_scene.instantiate()

	get_parent().add_child(projectile)
	projectile.global_position = global_position
	projectile.set_target(
		player.global_position + Vector3.UP * 0.7,
		self
	)


func take_hit() -> void:
	set_process(false)
	queue_free()
