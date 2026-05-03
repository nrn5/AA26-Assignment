class_name SteeringLibrary

# { SEEK }
# move agent directly towards a target 
static func seek(agent_pos: Vector3, target_pos: Vector3) -> Vector3:
	var desired = (target_pos - agent_pos).normalized()
	return desired
