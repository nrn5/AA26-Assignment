extends CanvasLayer

@onready var dialogue_panel = $pnlDialogue
@onready var feed_panel = $pnlFeed

@onready var text_label = $pnlDialogue/VBoxContainer/EmotionText

@onready var good_slider = $pnlFeed/VBoxContainer/GoodFood
@onready var bad_slider = $pnlFeed/VBoxContainer/BadFood

@onready var good_food_lbl = $pnlFeed/VBoxContainer/lblGoodFood
@onready var bad_food_lbl = $pnlFeed/VBoxContainer/lblBadFood

var current_alien = null
signal closed

# { UI CONTROL }
func open(alien):
	current_alien = alien
	show()
	dialogue_panel.show()
	feed_panel.hide()

	update_dialogue()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_set_player_control(false)
	if current_alien:
		current_alien.frozen = true

func close():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if current_alien:
		current_alien.frozen = false
	current_alien = null

	_set_player_control(true)
	emit_signal("closed")

# { PLAYER CONTROL }
func _set_player_control(enabled: bool):
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	player.can_look = enabled
	player.can_move = enabled

# { DIALOGUE }
func update_dialogue():
	if current_alien == null:
		return
	var emotion = current_alien.brain.currentEmotion

	match emotion:
		current_alien.brain.EmotionalState.CURIOUS:
			text_label.text = "The alien watches you silently..."
		current_alien.brain.EmotionalState.TRUSTING:
			text_label.text = "It seems calm around you."
		current_alien.brain.EmotionalState.FEARFUL:
			text_label.text = "It keeps its distance..."
		current_alien.brain.EmotionalState.AGGRESSIVE:
			text_label.text = "It growls at you."
		current_alien.brain.EmotionalState.PLAYFUL:
			text_label.text = "It tilts its head curiously."

# { BUTTONS }
func _on_feed_pressed():
	dialogue_panel.hide()
	feed_panel.show()
	refresh_feed_ui()

func _on_back_pressed():
	close()

func _on_exit_pressed():
	close()

# { FEED SYSTEM }
func _on_feed_confirm_pressed():
	if current_alien == null:
		print("ERROR: current_alien is null")
		return
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("ERROR: player is null")
		return

	var good = int(good_slider.value)
	var bad = int(bad_slider.value)
	print("Slider values — good: ", good, " bad: ", bad)

	if good == 0 and bad == 0:
		print("ERROR: both sliders are 0, returning early")
		return

	good = min(good, player.good_food)
	bad = min(bad, player.bad_food)
	print("After clamp — good: ", good, " bad: ", bad, " | player has: ", player.good_food, " good, ", player.bad_food, " bad")

	player.good_food -= good
	player.bad_food -= bad
	if player.has_signal("food_updated"):
		player.food_updated.emit(player.good_food, player.bad_food)

	print("Calling receive_food on: ", current_alien)
	current_alien.receive_food(good, bad)

	good_slider.value = 0
	bad_slider.value = 0
	update_dialogue()
	feed_panel.hide()
	dialogue_panel.show()
	
# { UI REFRESH }
func refresh_feed_ui():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	good_slider.max_value = player.good_food
	bad_slider.max_value = player.bad_food

	good_food_lbl.text = "Good food count: " + str(player.good_food)
	bad_food_lbl.text = "Bad food count: " + str(player.bad_food)

	good_slider.value = 0
	bad_slider.value = 0
