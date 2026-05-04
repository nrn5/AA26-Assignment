class_name Avoidance
extends SteeringBehaviour

@export var feeler_length := 6.0
@export var feeler_angle := 45.0
@export var avoidance_strength := 3.0
@export var feeler_count := 5

var avoidance_force := Vector3.ZERO
var space_state: PhysicsDirectSpaceState3D

func _ready():
	await get_tree().process_frame

	if agent == null:
		push_error("Avoidance: agent not assigned")
		return
	space_state = agent.get_world_3d().direct_space_state

# { OUTPUT }
func calculate() -> Vector3:
	return avoidance_force * weight

# { PHYSICS }
func _physics_process(_delta):
	if agent == null or space_state == null:
		return
	update_feelers()

# { UPDATE FEELERS }
func update_feelers():
	# reset each frame
	avoidance_force = Vector3.ZERO

	var forward = -agent.global_transform.basis.z
	var right = forward.cross(Vector3.UP).normalized()

	var dirs = [forward,
				forward.rotated(Vector3.UP, deg_to_rad(feeler_angle)),
				forward.rotated(Vector3.UP, deg_to_rad(-feeler_angle)),
				right,
				-right]
	for d in dirs:
		cast_feeler(d.normalized())

# { RAYCAST }
func cast_feeler(dir: Vector3):
	var start = agent.global_position
	start.y += 0.2  # keep rays aligned to ground height
	var end = start + dir * feeler_length
	dir.y = 0
	dir = dir.normalized()

	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [agent]
	var hit = space_state.intersect_ray(query)
	# no wall detected so weak forward bias so we dont stall
	if hit.is_empty():
		avoidance_force += dir * 0.05
		return
	# hit wall so push away based on angle + distance
	var normal = hit.normal
	normal.y = 0
	normal = normal.normalized()

	var incidence = clamp(-dir.dot(normal), 0.0, 1.0)
	var dist = (hit.position - start).length()
	var falloff = 1.0 - (dist / feeler_length)

	avoidance_force += normal * incidence * falloff * avoidance_strength

# { DEBUG }
func on_draw_gizmos():
	if agent == null:
		return
	var start = agent.global_position
	start.y += 0.2

	var forward = -agent.global_transform.basis.z
	var right = forward.cross(Vector3.UP).normalized()

	var dirs = [forward,
				forward.rotated(Vector3.UP, deg_to_rad(feeler_angle)),
				forward.rotated(Vector3.UP, deg_to_rad(-feeler_angle)),
				right,
				-right]
	for d in dirs:
		var end = start + d * feeler_length
		DebugDraw3D.draw_line(start, end, Color(0.2, 0.6, 1.0))

		var hit = _debug_raycast(d)
		if hit.size() > 0:
			DebugDraw3D.draw_sphere(hit.position, 0.15, Color.RED)
			DebugDraw3D.draw_line(hit.position, hit.position + hit.normal, Color.YELLOW)
	DebugDraw3D.draw_line(start, start + avoidance_force, Color(1, 0.2, 0.2))

func _debug_raycast(dir: Vector3) -> Dictionary:
	var start = agent.global_position
	start.y += 0.2

	var end = start + dir * feeler_length
	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [agent]

	return space_state.intersect_ray(query)
