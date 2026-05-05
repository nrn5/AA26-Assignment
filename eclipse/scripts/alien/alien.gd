class_name Alien
extends CharacterBody3D

@onready var wander = $n3DSteering/n3DWander
@onready var avoidance = $n3DSteering/n3DAvoid
@onready var seek = $n3DSteering/n3DSeek
@onready var flee = $n3DSteering/n3DFlee
@onready var brain = $Brain
@onready var sfx: AudioStreamPlayer3D = $a3DMunch
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $alien_strut/AnimationPlayer

@export var speed := 3.0
@export var turn_speed := 6.0

var damage_timer := 0.0
@export var attack_range := 2.0
@export var attack_cooldown := 0.6

var frozen := false
var nav_ready := false
var _exit_position := Vector3.ZERO

func _ready():
	_init_steering()
	_init_navigation()

# { INIT }
func _init_steering():
	wander.agent = self
	avoidance.agent = self
	seek.agent = self
	flee.agent = self
	flee.target = get_tree().get_first_node_in_group("player")
	seek.target = get_tree().get_first_node_in_group("player")

func _init_navigation():
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0

func _physics_process(delta):
	velocity.y = 0
	_handle_attack(delta)

	if frozen:
		if anim_player.is_playing():
			anim_player.pause()
		velocity = Vector3.ZERO
		move_and_slide()
		return
	else:
		if not anim_player.is_playing():
			anim_player.play()

	var move_force  = _calculate_behavior_force()
	var avoid_force = avoidance.calculate()
	var final_force = move_force + avoid_force

	_apply_movement(final_force)
	_apply_rotation(delta)
	velocity.y = 0

# { COMBAT }
func _handle_attack(delta):
	if frozen:
		return
	if brain.currentBehavior != brain.BehaviorState.PURSUE_PLAYER:
		return
	if seek.target == null:
		return

	var player = seek.target
	if player.has_method("take_damage") == false:
		return
	if player.dead:
		return

	var dist = global_position.distance_to(player.global_position)
	if dist > attack_range:
		damage_timer = 0.0
		return
	# cooldown
	damage_timer -= delta
	if damage_timer > 0.0:
		return
	# damage
	var dmg = randi_range(10, 20)
	player.take_damage(dmg)

	damage_timer = attack_cooldown

# { BEHAVIOUR SYSTEM }
func _calculate_behavior_force() -> Vector3:
	match brain.currentBehavior:
		brain.BehaviorState.WANDER:
			return wander.calculate()
		brain.BehaviorState.SEEK_PLAYER:
			return seek.calculate()
		brain.BehaviorState.PURSUE_PLAYER:
			return _nav_force_toward(seek.target.global_position)
		brain.BehaviorState.GUIDE_PLAYER:
			return _nav_force_toward(_exit_position)
		brain.BehaviorState.AVOID_PLAYER:
			return flee.calculate()

	return Vector3.ZERO

# { NAVIGATION CONTROL }
func enable_navigation():
	await get_tree().process_frame
	nav_ready = true
	# debug check
	nav_agent.target_position = _exit_position
	await get_tree().process_frame

func _nav_force_toward(world_target: Vector3) -> Vector3:
	if not nav_ready:
		return Vector3.ZERO
	if world_target == Vector3.ZERO:
		return Vector3.ZERO

	nav_agent.target_position = world_target

	if nav_agent.is_navigation_finished():
		return Vector3.ZERO

	var next = nav_agent.get_next_path_position()
	DebugDraw3D.draw_sphere(next, 0.2, Color.YELLOW)

	var dir = next - global_position
	dir.y = 0

	if dir.length_squared() < 0.001:
		return Vector3.ZERO
	return dir.normalized() * speed

# { MOVEMENT }
func _apply_movement(force: Vector3):
	force.y = 0 
	if force.length() > speed:
		force = force.normalized() * speed

	velocity.x = force.x
	velocity.z = force.z
	velocity.y = 0 
	move_and_slide()

# { ROTATION }
func _apply_rotation(delta):
	if velocity.length_squared() <= 0.001:
		return
	var target_dir  = velocity.normalized()
	var current_fwd = -global_transform.basis.z

	var new_fwd = current_fwd.slerp(target_dir, turn_speed * delta).normalized()
	look_at(global_position + new_fwd, Vector3.UP)

# { INTERACTION }
func receive_food(good: float, bad: float):
	brain.on_fed(good, bad)
	_play_munch()

func _play_munch():
	if sfx:
		sfx.play()
