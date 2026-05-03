class_name Arrive
extends SteeringBehaviour

@export var target_path: NodePath
@export var slow_radius := 5.0
@export var max_speed := 4.0

var target: Node3D

func _ready():
	if target_path:
		target = get_node(target_path)

func calculate() -> Vector3:
	if target == null:
		return Vector3.ZERO
	var to_target = target.global_position - agent.global_position
	var dist = to_target.length()

	if dist < 0.1:
		return Vector3.ZERO
	var speed_factor = min(dist / slow_radius, 1.0)
	var desired_velocity = to_target.normalized() * speed_factor * max_speed

	return (desired_velocity - agent.velocity) * weight

func on_draw_gizmos():
	if !drawGizmos or target == null:
		return
	# target marker
	DebugDraw3D.draw_position(target.global_transform, Color.AQUAMARINE)

	# slow radius
	DebugDraw3D.draw_sphere(target.global_position, slow_radius, Color.AQUAMARINE)

	# direction line,, agent to target
	DebugDraw3D.draw_line(agent.global_position, target.global_position, Color.AQUAMARINE)
