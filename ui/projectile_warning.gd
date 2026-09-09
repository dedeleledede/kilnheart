extends Label

@export var camera_path: NodePath
@export var player_path: NodePath

@onready var camera: Camera3D = get_node(camera_path)
@onready var player: Node3D = get_node(player_path)


func _ready() -> void:
	text = "▲"
	size = Vector2(48, 48)
	pivot_offset = size / 2.0

	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	add_theme_font_size_override("font_size", 36)
	add_theme_color_override(
		"font_color",
		Color(1.0, 0.25, 0.15)
	)
	add_theme_constant_override("outline_size", 6)
	add_theme_color_override(
		"font_outline_color",
		Color.BLACK
	)

	visible = false


func _process(_delta: float) -> void:
	var projectile := find_closest_projectile()

	if projectile == null:
		visible = false
		return

	var viewport_size := get_viewport_rect().size
	var screen_position := camera.unproject_position(
		projectile.global_position
	)

	var behind_camera := camera.is_position_behind(
		projectile.global_position
	)

	var safe_screen_area := Rect2(
		Vector2(32, 32),
		viewport_size - Vector2(64, 110)
	)

	if (
		not behind_camera
		and safe_screen_area.has_point(screen_position)
	):
		visible = false
		return

	var camera_position := camera.to_local(
		projectile.global_position
	)

	var direction := Vector2(
		camera_position.x,
		camera_position.z
	)

	if direction.length_squared() <= 0.001:
		visible = false
		return

	direction = direction.normalized()

	var indicator_x := viewport_size.x * 0.5
	indicator_x += direction.x * viewport_size.x * 0.35
	indicator_x = clamp(
		indicator_x,
		40.0,
		viewport_size.x - 40.0
	)

	position = Vector2(
		indicator_x - size.x * 0.5,
		viewport_size.y - 80.0
	)

	rotation = direction.angle() + PI * 0.5
	visible = true


func find_closest_projectile() -> Node3D:
	var closest: Node3D = null
	var closest_distance := INF

	for node in get_tree().get_nodes_in_group(
		"hostile_projectile"
	):
		var projectile := node as Node3D

		if projectile == null:
			continue

		if projectile.has_method("should_warn"):
			var should_show = projectile.call(
				"should_warn",
				player.global_position,
				camera
			)

			if should_show != true:
				continue

		var distance := player.global_position.distance_to(
			projectile.global_position
		)

		if distance < closest_distance:
			closest = projectile
			closest_distance = distance

	return closest
