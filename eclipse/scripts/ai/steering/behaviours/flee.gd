class_name Flee
extends SteeringBehaviour

@export var target_path: NodePath
@export var flee_range := 50.0

var target: Node3D

func _ready():
	if target_path:
		target = get_node(target_path)

func calculate() -> Vector3:
	if target == null:
		return Vector3.ZERO

	var away := agent.global_position - target.global_position
	var dist := away.length()

	if dist > flee_range:
		return Vector3.ZERO

	if dist < 0.001:
		return Vector3.ZERO

	return away.normalized() * agent.speed
