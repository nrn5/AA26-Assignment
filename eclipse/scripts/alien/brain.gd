extends Node
class_name AlienBrain

@export var debug_emotions := true
@onready var agent: CharacterBody3D = get_parent()

var trust := 50.0

enum EmotionalState {
	CURIOUS,
	FEARFUL,
	AGGRESSIVE,
	PLAYFUL,
	TRUSTING
}
var currentEmotion: EmotionalState = EmotionalState.CURIOUS

enum BehaviorState {
	WANDER,
	SEEK_PLAYER,
	PURSUE_PLAYER,
	AVOID_PLAYER,
	GUIDE_PLAYER
}
var currentBehavior: BehaviorState = BehaviorState.WANDER

var fear        := 0.0
var aggression  := 0.0
var playfulness := 0.0

@export var decay_rate := 0.01

var player: Node3D = null

signal trust_changed(value: float)

func _process(delta):
	_apply_decay(delta)
	_update_emotion()
	_update_behavior()

# FEEDING INPUT
func on_fed(good: float, bad: float):
	trust += good * 8.0   # was 2.0
	trust -= bad  * 8.0   # was 2.0
	trust  = clamp(trust, 0.0, 100.0)

	fear += bad  * 2.0  
	playfulness += good * 2.0  
	aggression += bad  * 2.0  

	trust_changed.emit(trust)
	_debug("Trust now: %.2f" % trust)
	_update_emotion()

# EMOTION DECISION
# Trust ranges:
#   90-100 = TRUSTING  (guides)
#   60-90 = PLAYFUL
#   40-60 = CURIOUS
#   10-40 = FEARFUL
#   0-10  = AGGRESSIVE (attacks)
func _update_emotion():
	var previous = currentEmotion

	if trust <= 10.0:
		currentEmotion = EmotionalState.AGGRESSIVE
	elif trust <= 40.0:
		currentEmotion = EmotionalState.FEARFUL
	elif trust <= 60.0:
		currentEmotion = EmotionalState.CURIOUS
	elif trust < 90.0:
		currentEmotion = EmotionalState.PLAYFUL
	else:
		currentEmotion = EmotionalState.TRUSTING
		
	if previous != currentEmotion:
		_enter_emotion(currentEmotion)

# BEHAVIOUR DECISION
func _update_behavior():
	var previous = currentBehavior
	match currentEmotion:
		EmotionalState.CURIOUS:
			currentBehavior = BehaviorState.SEEK_PLAYER
		EmotionalState.PLAYFUL:
			currentBehavior = BehaviorState.WANDER
		EmotionalState.TRUSTING:
			currentBehavior = BehaviorState.GUIDE_PLAYER
		EmotionalState.FEARFUL:
			currentBehavior = BehaviorState.AVOID_PLAYER
		EmotionalState.AGGRESSIVE:
			currentBehavior = BehaviorState.PURSUE_PLAYER
	if previous != currentBehavior:
		_enter_behavior(currentBehavior)

# STATE ENTRY
func _enter_emotion(state):
	match state:
		EmotionalState.CURIOUS:    _debug("Emotion → CURIOUS")
		EmotionalState.PLAYFUL:    _debug("Emotion → PLAYFUL")
		EmotionalState.TRUSTING:   _debug("Emotion → TRUSTING")
		EmotionalState.FEARFUL:    _debug("Emotion → FEARFUL")
		EmotionalState.AGGRESSIVE: _debug("Emotion → AGGRESSIVE")

func _enter_behavior(state):
	match state:
		BehaviorState.WANDER:        _debug("Behaviour → WANDER")
		BehaviorState.SEEK_PLAYER:   _debug("Behaviour → SEEK_PLAYER")
		BehaviorState.PURSUE_PLAYER: _debug("Behaviour → PURSUE_PLAYER")
		BehaviorState.AVOID_PLAYER:  _debug("Behaviour → AVOID_PLAYER")
		BehaviorState.GUIDE_PLAYER:  _debug("Behaviour → GUIDE_PLAYER")

# DECAY
func _apply_decay(delta):
	fear        = max(fear        - decay_rate * delta, 0)
	aggression  = max(aggression  - decay_rate * delta, 0)
	playfulness = max(playfulness - decay_rate * delta, 0)

# DEBUG
func _debug(msg: String):
	if debug_emotions:
		print("[AlienBrain] ", msg)
