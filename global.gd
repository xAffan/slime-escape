extends Node

var playerHP = 100
var LEVEL = 1

@onready var hp_label = $PlayerHPLabel  # Reference to the Label node

func take_damage(amount):
	print("take_damage called with amount:", amount)  # Debug message
	playerHP -= amount
	print("Player HP:", playerHP)
	update_hp_label()  # Update the HP display
	HUD.dmg_sound()
	var player = get_tree().get_current_scene().get_node("Player/Player")  # Adjust path if necessary
	if player:
		print("Player node found:", player)
		if player.has_method("take_damage"):
			print("Calling player.take_damage()")
			player.take_damage()
		else:
			print("Player node does not have take_damage method")
	else:
		print("Player node not found")
	if playerHP <= 0:
		on_player_death()

func update_hp_label():
	HUD.update_hp_label(playerHP)  # Reset HP display

func on_player_death():
	print("Player has died!")  # Debugging line
	#anim.play("Damage")  # Optional: Play damage or death animation
	# Restart the level or show a game-over screen
	playerHP = 100
	update_hp_label()
	HUD.dmg_sound()
	get_tree().reload_current_scene()
