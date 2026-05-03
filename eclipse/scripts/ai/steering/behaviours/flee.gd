class_name Flee
extends SteeringBehaviour

@export var target_path: NodePath
@export var flee_range := 50.0
@export var max_speed := 5.0

var target: Node3D

func _ready():
	if target_path:
		target = get_node(target_path)

func calculate() -> Vector3:
	if target == null:
		return Vector3.ZERO
	var away = agent.global_position - target.global_position
	var dist = away.length()

	if dist > flee_range:
		return Vector3.ZERO
	var desired_velocity = away.normalized() * max_speed

	return (desired_velocity - agent.velocity) * weight

func on_draw_gizmos():
	if !drawGizmos or target == null:
		return
	DebugDraw3D.draw_sphere(target.global_position, flee_range, Color.RED)
