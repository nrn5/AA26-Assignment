class_name Cohesion
extends SteeringBehaviour

@export var neighbours: Array[Node3D] = []

var center_of_mass := Vector3.ZERO

func calculate() -> Vector3:
	if neighbours.is_empty():
		return Vector3.ZERO
	var center := Vector3.ZERO
	var count := 0

	for n in neighbours:
		if n != null:
			center += n.global_position
			count += 1
	if count == 0:
		return Vector3.ZERO
	center_of_mass = center / count
	var to_center = center_of_mass - agent.global_position
	var desired_velocity = to_center.normalized()
	
	return (desired_velocity - agent.velocity) * weight

func on_draw_gizmos():
	if !drawGizmos:
		return
	if neighbours.is_empty():
		return
	DebugDraw3D.draw_line(agent.global_position, center_of_mass, 
						  Color.DARK_SEA_GREEN)
	DebugDraw3D.draw_sphere(center_of_mass, 0.5, Color.DARK_SEA_GREEN)
