class_name Wander
extends SteeringBehaviour

@export var distance := 20.0
@export var radius := 10.0
@export var jitter := 2.0

var wander_target := Vector3.ZERO
var world_target := Vector3.ZERO

func _ready():
	wander_target = random_unit_sphere() * radius

func calculate() -> Vector3:
	var delta = get_process_delta_time()
	wander_target += random_unit_sphere() * jitter * delta
	wander_target = wander_target.limit_length(radius)
	
	var local_target = Vector3.FORWARD * distance + wander_target
	world_target = agent.global_position + agent.global_transform.basis * local_target
	
	var to_target = world_target - agent.global_position
	var desired_velocity = to_target.normalized()
	
	return (desired_velocity - agent.velocity) * weight

func on_draw_gizmos():
	if !drawGizmos:
		return
	var center = agent.global_position + agent.global_transform.basis * Vector3.FORWARD * distance
	# wander influence area
	DebugDraw3D.draw_sphere(center, radius, Color.BLUE)
	# agent to wander center
	DebugDraw3D.draw_line(agent.global_position, center, Color.BLUE)
	# center to final wander target
	DebugDraw3D.draw_line(center, world_target, Color.PURPLE)

func random_unit_sphere() -> Vector3:
	return Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
