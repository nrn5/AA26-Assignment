class_name Wander
extends SteeringBehaviour

@export var forward_offset_distance := 3.0
@export var wander_radius := 2.0

@export var angle_change_speed := 2.5      
@export var change_interval := 1.0     
@export var move_speed := 3.0

var current_angle := 0.0
var target_angle := 0.0
var change_timer := 0.0
var current_direction := Vector3.FORWARD
var debug_center := Vector3.ZERO
var debug_target := Vector3.ZERO

func calculate() -> Vector3:
	var delta := get_process_delta_time()

	change_timer -= delta
	if change_timer <= 0.0:
		target_angle = randf_range(-PI, PI)
		change_timer = change_interval

	current_angle = lerp_angle(current_angle, target_angle, angle_change_speed * delta)

	var forward := -agent.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	var circle_center := agent.global_position
	debug_center = circle_center

	var offset := Vector3(cos(current_angle), 0, sin(current_angle)) * wander_radius

	var target := circle_center + offset
	debug_target = target

	var desired_dir := target - agent.global_position
	desired_dir.y = 0

	if desired_dir.length_squared() < 0.0001:
		return Vector3.ZERO
	desired_dir = desired_dir.normalized()

	current_direction = current_direction.lerp(desired_dir, 6.0 * delta)
	current_direction.y = 0
	current_direction = current_direction.normalized()

	return current_direction * move_speed

func on_draw_gizmos():
	if agent == null or !draw_gizmos:
		return
	# curr direction
	DebugDraw3D.draw_line(agent.global_position, agent.global_position + current_direction * 2.0,
						  Color.YELLOW)
	# target point
	DebugDraw3D.draw_sphere(debug_target, 0.2, Color.PURPLE)
	# circle
	DebugDraw3D.draw_sphere(debug_center, wander_radius, Color.GREEN)
