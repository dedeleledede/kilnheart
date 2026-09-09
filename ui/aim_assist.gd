extends Control

@export_group("References")
@export var camera_path := NodePath(
	"../../Player/CameraPivot/SpringArm3D/Camera3D"
)

@export_group("Aim Movement")
@export var mouse_sensitivity := 1.0
@export var screen_margin := 24.0

@export_group("Lock-on")
@export var lock_radius_pixels := 120.0
@export var release_radius_pixels := 95.0
@export var maximum_lock_distance := 45.0
@export var fallback_target_height := 0.6

@export_group("Appearance")
@export var box_size := 72.0
@export var line_width := 2.0
@export var crosshair_size := 10.0
@export var crosshair_gap := 4.0

@export var normal_color := Color(
	0.85,
	0.85,
	0.80,
	0.75
)

@export var locked_color := Color(
	1.0,
	0.65,
	0.15,
	1.0
)

@onready var camera: Camera3D = get_node(
	camera_path
)

var aim_position := Vector2.ZERO
var locked_target: Node3D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	await get_tree().process_frame

	aim_position = size * 0.5
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	queue_redraw()


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		move_aim(event.relative)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if (
		event is InputEventMouseButton
		and event.pressed
		and Input.mouse_mode
			!= Input.MOUSE_MODE_CAPTURED
	):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func move_aim(mouse_motion: Vector2) -> void:
	aim_position += (
		mouse_motion
		* mouse_sensitivity
	)

	aim_position.x = clamp(
		aim_position.x,
		screen_margin,
		size.x - screen_margin
	)

	aim_position.y = clamp(
		aim_position.y,
		screen_margin,
		size.y - screen_margin
	)

	queue_redraw()


func _process(_delta: float) -> void:
	update_lock_target()
	queue_redraw()


func update_lock_target() -> void:
	if can_keep_current_target():
		return

	locked_target = null

	var closest_target: Node3D = null
	var closest_screen_distance := INF

	for node in get_tree().get_nodes_in_group(
		"aim_target"
	):
		var target := node as Node3D

		if not is_target_available(target):
			continue

		var target_position := get_target_position(
			target
		)

		var screen_position := (
			camera.unproject_position(
				target_position
			)
		)

		var screen_distance := (
			aim_position.distance_to(
				screen_position
			)
		)

		if screen_distance > lock_radius_pixels:
			continue

		if screen_distance < closest_screen_distance:
			closest_target = target
			closest_screen_distance = screen_distance

	locked_target = closest_target


func can_keep_current_target() -> bool:
	if not is_target_available(locked_target):
		return false

	var screen_position := camera.unproject_position(
		get_target_position(locked_target)
	)

	return (
		aim_position.distance_to(screen_position)
		<= release_radius_pixels
	)


func is_target_available(target: Node3D) -> bool:
	if not is_instance_valid(target):
		return false

	var target_position := get_target_position(target)

	if camera.is_position_behind(target_position):
		return false

	if (
		camera.global_position.distance_to(
			target_position
		)
		> maximum_lock_distance
	):
		return false

	var screen_position := camera.unproject_position(
		target_position
	)

	return Rect2(
		Vector2.ZERO,
		size
	).has_point(screen_position)


func get_target_position(
	target: Node3D
) -> Vector3:
	if target.has_method("get_aim_position"):
		return target.call("get_aim_position")

	return (
		target.global_position
		+ Vector3.UP * fallback_target_height
	)


func get_aim_direction(
	projectile_origin: Vector3
) -> Vector3:
	if is_target_available(locked_target):
		return projectile_origin.direction_to(
			get_target_position(locked_target)
		)

	var ray_origin := camera.project_ray_origin(
		aim_position
	)

	var ray_direction := camera.project_ray_normal(
		aim_position
	)

	var distant_aim_point := (
		ray_origin
		+ ray_direction * 100.0
	)

	return projectile_origin.direction_to(
		distant_aim_point
	)


func _draw() -> void:
	draw_crosshair()

	var box_position := aim_position
	var box_color := normal_color

	if is_target_available(locked_target):
		box_position = camera.unproject_position(
			get_target_position(locked_target)
		)

		box_color = locked_color

	draw_lock_box(
		box_position,
		box_color
	)


func draw_crosshair() -> void:
	var color := normal_color

	draw_line(
		aim_position + Vector2(
			-crosshair_size,
			0
		),
		aim_position + Vector2(
			-crosshair_gap,
			0
		),
		color,
		line_width
	)

	draw_line(
		aim_position + Vector2(
			crosshair_gap,
			0
		),
		aim_position + Vector2(
			crosshair_size,
			0
		),
		color,
		line_width
	)

	draw_line(
		aim_position + Vector2(
			0,
			-crosshair_size
		),
		aim_position + Vector2(
			0,
			-crosshair_gap
		),
		color,
		line_width
	)

	draw_line(
		aim_position + Vector2(
			0,
			crosshair_gap
		),
		aim_position + Vector2(
			0,
			crosshair_size
		),
		color,
		line_width
	)


func draw_lock_box(
	center: Vector2,
	color: Color
) -> void:
	var box_rect := Rect2(
		center - Vector2.ONE * box_size * 0.5,
		Vector2.ONE * box_size
	)

	draw_rect(
		box_rect,
		color,
		false,
		line_width
	)
