class_name Avoidance
extends SteeringBehaviour

@export var obstacles: Array[Node3D] = []
@export var feeler_length := 10.0
@export var feeler_angle := 45.0
@export var updates_per_second := 5

var force := Vector3.ZERO
var feelers := []
var space_state: PhysicsDirectSpaceState3D
var needs_update := true

func _ready():
	space_state = agent.get_world_3d().direct_space_state
	# stagger updates so multiple agents dont snyc
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = randf_range(0.0, 1.0)
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "start_updating"))
	timer.start()

func start_updating():
	var timer = get_child(0)
	timer.wait_time = 1.0 / updates_per_second
	timer.one_shot = false
	timer.timeout.connect(_on_update_tick)
	timer.start()

func _on_update_tick():
	needs_update = true

func _physics_process(delta):
	if needs_update:
		update_feelers()
		needs_update = false

func calculate() -> Vector3:
	return force * weight

func update_feelers():
	force = Vector3.ZERO
	feelers.clear()

	var forward = -agent.global_transform.basis.z * feeler_length
	# main forward feeler
	feelers.append(cast_feeler(forward))
	# side feelers (spread)
	feelers.append(cast_feeler(Quaternion(Vector3.UP, deg_to_rad(feeler_angle)) * forward))
	feelers.append(cast_feeler(Quaternion(Vector3.UP, deg_to_rad(-feeler_angle)) * forward))

	feelers.append(cast_feeler(Quaternion(Vector3.RIGHT, deg_to_rad(feeler_angle)) * forward))
	feelers.append(cast_feeler(Quaternion(Vector3.RIGHT, deg_to_rad(-feeler_angle)) * forward))

func cast_feeler(local_ray: Vector3) -> Dictionary:
	var result_data = {}
	var start = agent.global_position
	var end = agent.global_transform * local_ray
	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [agent]
	var result = space_state.intersect_ray(query)

	result_data["end"] = end
	result_data["hit"] = result

	if result:
		var hit_position = result.position
		var normal = result.normal

		result_data["hitPosition"] = hit_position
		result_data["normal"] = normal

		var to_agent = agent.global_position - hit_position
		var distance_factor = (feeler_length - to_agent.length()) / feeler_length
		var avoidance_factor = Vector3.ZERO

		avoidance_factor = normal * distance_factor
		force += avoidance_factor

	return result_data
