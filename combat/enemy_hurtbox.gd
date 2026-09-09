extends Area3D


@export var parried_projectile_damage := 2


func _ready() -> void:
	collision_layer = 1 << 2
	collision_mask = 0
	monitorable = true


func receive_parried_projectile(
	_projectile: Area3D
) -> void:
	deal_damage(
		parried_projectile_damage
	)


func receive_melee_attack(
	damage: int,
	_hit_origin: Vector3
) -> void:
	deal_damage(damage)


func deal_damage(damage: int) -> void:
	var enemy := get_parent()

	if enemy.has_method("take_damage"):
		enemy.call(
			"take_damage",
			damage
		)
	elif enemy.has_method("take_hit"):
		enemy.call("take_hit")
