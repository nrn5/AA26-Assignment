class_name Pursue
extends SteeringBehaviour

@export var target_path: NodePath
# higher = more aggressive prediction
@export var prediction_time := 0.5
@export var max_speed := 5.0

var target: Node3D
var predicted_position := Vector3.ZERO

func _ready():
	if target_path:
		target = get_node(target_path)

func calculate() -> Vector3:
	if target == null:
		return Vector3.ZERO

	var agent_position = agent.global_position
	var target_position = target.global_position
	var future_position = target_position

	if "velocity" in target:
		future_position += target.velocity * prediction_time

	predicted_position = future_position
	var to_future = future_position - agent_position
	var desired_velocity = to_future.normalized() * max_speed

	return (desired_velocity - agent.velocity) * weight

func on_draw_gizmos():
	if !drawGizmos or target == null:
		return
	# current target position
	DebugDraw3D.draw_line(agent.global_position, target.global_position, Color.ORANGE)
	# predicted future position
	DebugDraw3D.draw_line(target.global_position, predicted_position, Color.RED)
	# visualise agent to predicted target
	DebugDraw3D.draw_line(agent.global_position, predicted_position, Color.YELLOW)
