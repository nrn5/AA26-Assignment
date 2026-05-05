extends Interactable

signal request_ui(alien)

func interact(player):
	print("Alien interacted")
	var alien = get_parent()
	emit_signal("request_ui", alien)
