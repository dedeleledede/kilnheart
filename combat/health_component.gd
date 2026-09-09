extends Node

signal damaged(
	damage: int,
	current_health: int
)

signal health_changed(
	current_health: int,
	max_health: int
)

signal died

@export var max_health := 4

var current_health := 0
var dead := false


func _ready() -> void:
	current_health = max_health

	health_changed.emit(
		current_health,
		max_health
	)


func take_damage(damage: int) -> void:
	if dead or damage <= 0:
		return

	current_health = max(
		current_health - damage,
		0
	)

	print(
		"ENEMY HP: ",
		current_health,
		"/",
		max_health
	)

	damaged.emit(
		damage,
		current_health
	)

	health_changed.emit(
		current_health,
		max_health
	)

	if current_health <= 0:
		dead = true
		died.emit()


func heal(amount: int) -> void:
	if dead or amount <= 0:
		return

	current_health = min(
		current_health + amount,
		max_health
	)

	health_changed.emit(
		current_health,
		max_health
	)
