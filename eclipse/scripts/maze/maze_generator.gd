extends Node3D
class_name MazeGenerator

@export var maze_area: Vector2i = Vector2i(12, 12)
@export var cell_size: float = 6.0
@export var wall_height: float = 3.0
@export var wall_thickness: float = 0.4
# player spawn area
@export var open_area_radius_x: int = 2
@export var open_area_radius_y: int = 2
# exit area
@export var exit_zone_radius: int = 2
# lights
@export var enable_lights: bool = true
@export var light_chance: float = 0.08
@export var light_height: float = 2.5
# food
@export var good_food_scene: PackedScene
@export var bad_food_scene: PackedScene
@export var food_spawn_chance := 0.15
@export var bad_food_ratio := 0.3
# boids
@export var boid_scene: PackedScene
@export var boid_count := 10
# space ship
@export var spaceship_scene: PackedScene
# materials
@export var wall_material: StandardMaterial3D
@export var floor_material: StandardMaterial3D
@export var floor_texture_scale := 2.0

var nav_region: NavigationRegion3D

var maze_data: Array = []  
var visited: Array = []    

var open_area_min: Vector2i
var open_area_max: Vector2i

var exit_area_min: Vector2i
var exit_area_max: Vector2i

signal navigation_ready

func _ready():
	generate_maze()
	setup_open_area()
	setup_exit_area()
	carve_center_open_area()
	carve_exit_area()
	carve_maze(0, 0)
	carve_exit_path()
	build_floor()
	build_walls()
	build_outer_bounds()
	create_exit_spaceship()

	if enable_lights:
		spawn_random_lights()

	await get_tree().process_frame
	build_navigation()
	spawn_food()
	spawn_boids()

# boids
func spawn_boids():
	if boid_scene == null:
		push_warning("Boid scene not assigned")
		return

	for i in range(boid_count):

		var boid = boid_scene.instantiate()
		add_child(boid)
		# pick a random cell outside spawn + exit
		var x := randi_range(0, maze_width() - 1)
		var y := randi_range(0, maze_height() - 1)

		while is_in_open_area(x, y) or is_in_exit_area(x, y):
			x = randi_range(0, maze_width() - 1)
			y = randi_range(0, maze_height() - 1)

		boid.global_position = cell_center(x, y) + Vector3(
			randf_range(-1, 1),
			0,
			randf_range(-1, 1))
		
# { NAVIGATION }
func build_navigation():
	await get_tree().process_frame
	await get_tree().process_frame
		
	var nav_mesh = NavigationMesh.new()
	nav_mesh.agent_height        = 2.0
	nav_mesh.agent_radius        = 0.4
	nav_mesh.agent_max_climb     = 0.3
	nav_mesh.agent_max_slope     = 30.0
	nav_mesh.cell_size           = 0.3
	nav_mesh.cell_height         = 0.2
	# use groups so control exactly what gets baked
	nav_mesh.geometry_source_geometry_mode = \
		NavigationMesh.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
	nav_mesh.geometry_source_group_name = "nav_source"
	nav_mesh.geometry_parsed_geometry_type = \
		NavigationMesh.PARSED_GEOMETRY_BOTH
	
	NavigationServer3D.map_set_cell_height(get_world_3d().navigation_map, 0.2)
	nav_region = NavigationRegion3D.new()
	nav_region.navigation_mesh = nav_mesh
	add_child(nav_region)

	nav_region.bake_finished.connect(_on_bake_finished)
	nav_region.bake_navigation_mesh(false)
	
func _on_bake_finished():
	print("Nav mesh baked!")
	print("Alien found: ", get_tree().get_first_node_in_group("alien"))  # ← add this
	var alien = get_tree().get_first_node_in_group("alien")
	if alien:
		alien._exit_position = cell_center(
			(exit_area_min.x + exit_area_max.x) / 2,
			(exit_area_min.y + exit_area_max.y) / 2)
		alien.enable_navigation()
	
func _bake_nav():
	# wait until walls are fully in scene tree
	await get_tree().process_frame
	await get_tree().process_frame
	nav_region.bake_navigation_mesh()

# { GRID HELPERS }
func maze_width() -> int:
	return maze_area.x

func maze_height() -> int:
	return maze_area.y

func cell_origin(x, y) -> Vector3:
	return Vector3(x * cell_size, 0, y * cell_size)

func cell_center(x, y) -> Vector3:
	return cell_origin(x, y) + Vector3(cell_size * 0.5, 0, cell_size * 0.5)

# { MAZE INIT }
func generate_maze():
	maze_data.clear()
	visited.clear()

	for y in range(maze_height()):
		var row = []
		var vrow = []

		for x in range(maze_width()):
			# each wall starts closed
			row.append({
				"north": true,
				"south": true,
				"east": true,
				"west": true
			})
			vrow.append(false)

		maze_data.append(row)
		visited.append(vrow)


# { OPEN AREA }
func setup_open_area():
	var cx = maze_width() / 2
	var cy = maze_height() / 2

	open_area_min = Vector2i(cx - open_area_radius_x, cy - open_area_radius_y)
	open_area_max = Vector2i(cx + open_area_radius_x, cy + open_area_radius_y)

func carve_center_open_area():
	for y in range(open_area_min.y, open_area_max.y + 1):
		for x in range(open_area_min.x, open_area_max.x + 1):
			if x < 0 or y < 0 or x >= maze_width() or y >= maze_height():
				continue
			var cell = maze_data[y][x]
			# open this cell
			cell.north = false
			cell.south = false
			cell.east = false
			cell.west = false

# { EXIT AREA }
func setup_exit_area():
	var margin = exit_zone_radius * 2
	exit_area_min = Vector2i(
		maze_width() - 1 - margin,
		maze_height() - 1 - margin)

	exit_area_max = Vector2i(
		maze_width() - 1,
		maze_height() - 1)
	# prevent overlap with spawn area
	if is_in_open_area(exit_area_min.x, exit_area_min.y):
		push_error("Exit overlaps open area")

func carve_exit_area():
	for y in range(exit_area_min.y, exit_area_max.y + 1):
		for x in range(exit_area_min.x, exit_area_max.x + 1):
			if x < 0 or y < 0 or x >= maze_width() or y >= maze_height():
				continue
			var cell = maze_data[y][x]
			cell.north = false
			cell.south = false
			cell.east = false
			cell.west = false

# { MAZE GENERATION (DFS) }
func carve_maze(x: int, y: int):
	visited[y][x] = true

	var dirs = [0, 1, 2, 3]
	dirs.shuffle()

	for dir in dirs:
		var nx = x
		var ny = y
		match dir:
			0: ny -= 1
			1: ny += 1
			2: nx += 1
			3: nx -= 1

		if nx < 0 or ny < 0 or nx >= maze_width() or ny >= maze_height():
			continue
		if visited[ny][nx]:
			continue
		# knock down walls between cells
		match dir:
			0:
				maze_data[y][x].north = false
				maze_data[ny][nx].south = false
			1:
				maze_data[y][x].south = false
				maze_data[ny][nx].north = false
			2:
				maze_data[y][x].east = false
				maze_data[ny][nx].west = false
			3:
				maze_data[y][x].west = false
				maze_data[ny][nx].east = false
		carve_maze(nx, ny)

# { FORCE PATH TO EXIT }
func carve_exit_path():
	var x = 0
	var y = 0
	while x != exit_area_min.x:
		if x < exit_area_min.x:
			maze_data[y][x].east = false
			maze_data[y][x + 1].west = false
			x += 1
		else:
			maze_data[y][x].west = false
			maze_data[y][x - 1].east = false
			x -= 1

	while y != exit_area_min.y:
		if y < exit_area_min.y:
			maze_data[y][x].south = false
			maze_data[y + 1][x].north = false
			y += 1
		else:
			maze_data[y][x].north = false
			maze_data[y - 1][x].south = false
			y -= 1

# { BUILDS }
func build_floor():
	for y in range(maze_height()):
		for x in range(maze_width()):

			var body = StaticBody3D.new()
			body.add_to_group("nav_source")

			var mesh = MeshInstance3D.new()
			var box = BoxMesh.new()
			box.size = Vector3(cell_size, 0.2, cell_size)

			# enable proper uv scaling
			box.subdivide_width = 1
			box.subdivide_depth = 1
			mesh.mesh = box
			# apply shared material
			if floor_material:
				mesh.material_override = floor_material
			body.add_child(mesh)

			var col = CollisionShape3D.new()
			var shape = BoxShape3D.new()
			shape.size = Vector3(cell_size, 0.2, cell_size)
			col.shape = shape
			body.add_child(col)

			body.position = cell_center(x, y) + Vector3(0, -0.1, 0)
			add_child(body)

func build_walls():
	for y in range(maze_height()):
		for x in range(maze_width()):

			var cell = maze_data[y][x]
			var origin = cell_origin(x, y)

			# NORTH wall (skip top row)
			if cell.north and y != 0:
				create_wall(
					origin + Vector3(cell_size * 0.5, 0, 0),
					Vector3(cell_size, wall_height, wall_thickness))

			# WEST wall (skip left edge)
			if cell.west and x != 0:
				create_wall(
					origin + Vector3(0, 0, cell_size * 0.5),
					Vector3(wall_thickness, wall_height, cell_size))

			# EAST wall (skip right edge)
			if cell.east and x != maze_width() - 1:
				create_wall(
					origin + Vector3(cell_size, 0, cell_size * 0.5),
					Vector3(wall_thickness, wall_height, cell_size))

			# SOUTH wall (skip bottom row)
			if cell.south and y != maze_height() - 1:
				create_wall(
					origin + Vector3(cell_size * 0.5, 0, cell_size),
					Vector3(cell_size, wall_height, wall_thickness))

func build_outer_bounds():
	var w = maze_width()
	var h = maze_height()
	# top + botton edges
	for x in range(w):
		# top
		create_wall(
			cell_origin(x, 0) + Vector3(cell_size * 0.5, 0, 0),
			Vector3(cell_size, wall_height, wall_thickness))
		# bottom
		create_wall(
			cell_origin(x, h - 1) + Vector3(cell_size * 0.5, 0, cell_size),
			Vector3(cell_size, wall_height, wall_thickness))

	# left + right edges
	for y in range(h):
		# left
		create_wall(
			cell_origin(0, y) + Vector3(0, 0, cell_size * 0.5),
			Vector3(wall_thickness, wall_height, cell_size))
		# right
		create_wall(
			cell_origin(w - 1, y) + Vector3(cell_size, 0, cell_size * 0.5),
			Vector3(wall_thickness, wall_height, cell_size))

func create_wall(pos: Vector3, size: Vector3):
	var wall = StaticBody3D.new()
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	# assign material
	if wall_material:
		box.material = wall_material
	mesh.mesh = box

	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	col.shape = shape

	wall.add_child(mesh)
	wall.add_child(col)

	wall.set_meta("navigation_mesh_source_geometry", true)
	wall.add_to_group("nav_source")

	wall.position = pos + Vector3(0, wall_height * 0.5, 0)
	add_child(wall)

# { EXIT }
func create_exit_spaceship():
	var center = cell_center(
		(exit_area_min.x + exit_area_max.x) / 2,
		(exit_area_min.y + exit_area_max.y) / 2)

	if spaceship_scene == null:
		push_warning("Spaceship scene not assigned")
		return
	var ship = spaceship_scene.instantiate()
	add_child(ship)

	ship.global_position = center + Vector3(0, 1.5, 0)

func _on_spaceship_entered(body):
	if body.is_in_group("player"):
		body.win()

# { LIGHTS }
func spawn_random_lights():
	for y in range(maze_height()):
		for x in range(maze_width()):

			if is_in_open_area(x, y):
				continue

			if randf() > light_chance:
				continue

			var light = OmniLight3D.new()
			light.light_energy = 2.0
			light.omni_range = 8.0
			light.light_color = Color(1.0, 0.85, 0.6)

			light.position = cell_center(x, y) + Vector3(0, light_height, 0)
			add_child(light)

# { FOOD }
func spawn_food():
	if good_food_scene == null or bad_food_scene == null:
		push_warning("Food scenes not assigned")
		return
	for y in range(maze_height()):
		for x in range(maze_width()):
			if is_in_open_area(x, y):
				continue
			if is_in_exit_area(x, y):
				continue
			if randf() > food_spawn_chance:
				continue
			var food = (bad_food_scene if randf() < bad_food_ratio else good_food_scene).instantiate()
			add_child(food)

			var offset = Vector3(
				randf_range(-cell_size * 0.2, cell_size * 0.2),
				0.5,
				randf_range(-cell_size * 0.2, cell_size * 0.2))
			food.global_position = cell_center(x, y) + offset
			food.add_to_group("food")

# { HELPERS }
func is_in_open_area(x: int, y: int) -> bool:
	return (
		x >= open_area_min.x and x <= open_area_max.x and
		y >= open_area_min.y and y <= open_area_max.y)

func is_in_exit_area(x: int, y: int) -> bool:
	return (
		x >= exit_area_min.x and x <= exit_area_max.x and
		y >= exit_area_min.y and y <= exit_area_max.y)

func get_open_area_center() -> Vector3:
	var cx = (open_area_min.x + open_area_max.x) / 2
	var cy = (open_area_min.y + open_area_max.y) / 2
	return cell_center(cx, cy)
