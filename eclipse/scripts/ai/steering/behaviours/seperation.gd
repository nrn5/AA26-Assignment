class_name Separation
extends SteeringBehaviour

@export var neighbours: Array[Node3D] = []
@export var radius := 3.0

var force := Vector3.ZERO

func calculate() -> Vector3:
	force = Vector3.ZERO
	if neighbours.is_empty():
		return Vector3.ZERO

	var count := 0
	for n in neighbours:
		if n == null:
			continue

		var away = agent.global_position - n.global_position
		var dist = away.length()

		if dist < radius and dist > 0.0001:
			force += away.normalized() / dist
			count += 1
	if count == 0:
		return Vector3.ZERO
		
	return force.normalized() * weight

func on_draw_gizmos():
	if !draw_gizmos:
		return
	if neighbours.is_empty():
		return
	# repulsion from each neighbor
	for n in neighbours:
		if n == null:
			continue
		var diff = agent.global_position - n.global_position
		var dist = diff.length()

		if dist < radius and dist > 0.0001:
			var dir = diff.normalized()
			DebugDraw3D.draw_line(agent.global_position,
								  agent.global_position + dir * 1.5,
								  Color.DARK_SEA_GREEN)
	# total separation force
	DebugDraw3D.draw_line(agent.global_position, agent.global_position + force * 2.0,
						  Color.RED)
	DebugDraw3D.draw_sphere(agent.global_position, radius, Color.BLUE)
