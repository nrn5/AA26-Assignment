class_name Seek
extends SteeringBehaviour

@export var target_path: NodePath
@export var max_speed := 4.0

var target: Node3D

func _ready():
	if target_path:
		target = get_node(target_path)

func calculate() -> Vector3:
	if target == null:
		return Vector3.ZERO
		
	var to_target = target.global_position - agent.global_position
	var desired_velocity = to_target.normalized() * max_speed

	return (desired_velocity - agent.velocity) * weight

func on_draw_gizmos():
	if !drawGizmos or target == null:
		return
	DebugDraw3D.draw_line(agent.global_position, target.global_position, 
						  Color.GREEN)
