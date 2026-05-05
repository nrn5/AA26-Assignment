class_name Seek
extends SteeringBehaviour

@export var target_path: NodePath
@export var move_speed := 3.0

var target: Node3D

func _ready():
	if target_path:
		target = get_node(target_path)

# { OUTPUT }
func calculate() -> Vector3:
	# safety checks
	if agent == null or target == null:
		return Vector3.ZERO
	# direction to target (flattened to ground plane)
	var dir = target.global_position - agent.global_position
	dir.y = 0
	# avoid jitter when extremely close
	if dir.length_squared() < 0.001:
		return Vector3.ZERO
	# normalize to convert to velocity
	dir = dir.normalized()
	return dir * move_speed

# { DEBUG }
func on_draw_gizmos():
	if !draw_gizmos or agent == null or target == null:
		return
	# draw direct line to target
	DebugDraw3D.draw_line(agent.global_position,target.global_position,Color.GREEN)
