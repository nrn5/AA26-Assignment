class_name Constrain
extends SteeringBehaviour

@export var radius := 100.0

var center: Node3D

func calculate() -> Vector3:
	var agent_pos = agent.global_position
	var center_pos = Vector3.ZERO
	if center != null:
		center_pos = center.global_position

	var to_center = center_pos - agent_pos
	var dist = to_center.length()

	if dist <= radius:
		return Vector3.ZERO
	var excess = dist - radius
	var desired_velocity = to_center.normalized() * excess

	return (desired_velocity - agent.velocity) * weight

func on_draw_gizmos():
	if !draw_gizmos:
		return

	var center_pos = Vector3.ZERO
	if center != null:
		center_pos = center.global_position

	DebugDraw3D.draw_sphere(center_pos, radius, Color.BEIGE)
	# correction direction (if outside bounds)
	var agent_pos = agent.global_position
	var to_center = center_pos - agent_pos
	var dist = to_center.length()

	if dist > radius:
		DebugDraw3D.draw_line(agent_pos, agent_pos + to_center.normalized() * (dist - radius),
							  Color.RED)
