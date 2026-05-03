class_name Alignment
extends SteeringBehaviour

# other agents influencing this one eg boids, NPCs, etc
@export var neighbours: Array[Node3D] = []

func calculate() -> Vector3:
	# if no neighbours then no alignment influence
	if neighbours.is_empty():
		return Vector3.ZERO
	var avd_velocity := Vector3.ZERO
	var count := 0

	for n in neighbours:
		if n != null and "velocity" in n:
			avd_velocity += n.velocity
			count += 1
	if count == 0:
		return Vector3.ZERO
	var desired_direction = (avd_velocity / count).normalized()
	# convert desired direction into a steering force
	var desired_velocity = desired_direction * agent.velocity.length()

	return (desired_velocity - agent.velocity) * weight

func on_draw_gizmos():
	if !drawGizmos:
		return
	if neighbours.is_empty():
		return

	var avg_direction := Vector3.ZERO
	var count := 0
	for n in neighbours:
		if n != null and "velocity" in n:
			avg_direction += n.velocity.normalized()
			count += 1
	if count == 0:
		return

	avg_direction = (avg_direction / count).normalized()
	# group direction consensus
	DebugDraw3D.draw_line(agent.global_position, 
						  agent.global_position + avg_direction * 3.0,
						  Color.YELLOW)
