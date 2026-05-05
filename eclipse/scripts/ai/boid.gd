extends CharacterBody3D

@export var speed := 2.5
@export var turn_speed := 6.0

@export var neighbour_radius := 6.0
@export var food_radius := 10.0
@export var wall_avoid_distance := 3.0

@export var cohesion_strength := 0.6
@export var separation_strength := 1.2
@export var food_attraction_strength := 2.0
@export var wander_strength := 0.4
@export var wall_strength := 3.0

var velocity_dir := -Vector3.FORWARD
var space_state: PhysicsDirectSpaceState3D

func _ready():
	space_state = get_world_3d().direct_space_state
	add_to_group("boid")

func _physics_process(delta):
	var accel := Vector3.ZERO

	accel += cohesion() * cohesion_strength
	accel += separation() * separation_strength
	accel += food_attraction() * food_attraction_strength
	accel += wander() * wander_strength
	accel += wall_avoidance() * wall_strength
	# smooth steering
	velocity_dir = (velocity_dir + accel * delta).normalized()
	# movement
	velocity = velocity_dir * speed
	move_and_slide()

	if is_on_wall():
		velocity_dir = velocity_dir.slide(get_wall_normal())
	rotate_towards_velocity(delta)

# BOIDS
func cohesion() -> Vector3:
	var avg := Vector3.ZERO
	var count := 0
	for b in get_tree().get_nodes_in_group("boid"):
		if b == self:
			continue

		var d := global_position.distance_to(b.global_position)
		if d < neighbour_radius:
			avg += b.global_position
			count += 1

	if count == 0:
		return Vector3.ZERO
	return ((avg / count) - global_position).normalized()

func separation() -> Vector3:
	var force := Vector3.ZERO
	for b in get_tree().get_nodes_in_group("boid"):
		if b == self:
			continue

		var diff = global_position - b.global_position
		var dist = diff.length()

		if dist < 2.0 and dist > 0.001:
			force += diff.normalized() / dist
	return force

func food_attraction() -> Vector3:
	var best := Vector3.ZERO
	var best_dist := food_radius

	for f in get_tree().get_nodes_in_group("food"):
		var d := global_position.distance_to(f.global_position)

		if d < best_dist:
			best_dist = d
			best = f.global_position

	if best == Vector3.ZERO:
		return Vector3.ZERO
	return (best - global_position).normalized()

func wander() -> Vector3:
	var rand_dir := Vector3(
		randf_range(-1, 1),
		0,
		randf_range(-1, 1))

	return rand_dir.normalized()

# WALL AVOIDANCE
func wall_avoidance() -> Vector3:
	var steer := Vector3.ZERO

	var dirs = [velocity_dir,
				velocity_dir.rotated(Vector3.UP, 0.7),
				velocity_dir.rotated(Vector3.UP, -0.7)]

	for dir in dirs:
		var from := global_position
		var to = from + dir * wall_avoid_distance

		var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))

		if !result.is_empty():
			var normal: Vector3 = result["normal"]
			steer += normal * (wall_avoid_distance / max(result["position"].distance_to(from), 0.1))
	return steer.normalized()

# ROTATION
func rotate_towards_velocity(delta):
	if velocity.length_squared() < 0.001:
		return
	var dir := velocity.normalized()

	var target := global_transform.looking_at(global_position + dir, Vector3.UP).basis
	target = target.orthonormalized()

	global_transform.basis = global_transform.basis.slerp(target, turn_speed * delta).orthonormalized()
