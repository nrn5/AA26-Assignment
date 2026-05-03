class_name SteeringLibrary

# { SEEK }
# move agent directly towards a target 
static func seek(agent_pos: Vector3, target_pos: Vector3) -> Vector3:
	return (target_pos - agent_pos).normalized()

# { FLEE }
# move agent away from a threat
static func flee(agent_pos: Vector3, threat_pos: Vector3) -> Vector3:
	return (agent_pos - threat_pos).normalized()
