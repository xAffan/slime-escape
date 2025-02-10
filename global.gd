extends Node

var playerHP = 100
var player2HP = 100
var LEVEL = 1
var tempHP
var playerScore = -1
var player2Score = -1

@onready var hp_label = $PlayerHPLabel  # Reference to the Label node

func take_damage(amount, playerName):
	print("take_damage called with amount:", amount, playerName)  # Debug message
	if playerName == "Player":
		tempHP = playerHP
	elif playerName == "Player2":
		tempHP = player2HP
	tempHP -= amount
	if tempHP <= 0:
		HUD.update_hp_label(0, playerName)
		if playerName == "Player":
			playerHP = 0
		elif playerName == "Player2":
			player2HP = 0
		on_player_death(playerName)
	else:
		print("Player HP:", tempHP)
		update_hp_label(tempHP, playerName)  # Update the HP display
		if playerName == "Player":
			playerHP = tempHP
		elif playerName == "Player2":
			player2HP = tempHP
		HUD.dmg_sound()
		var player
		if playerName == "Player":
			player = get_tree().get_current_scene().get_node("Player/Player")  # Adjust path if necessary
		else:
			player = get_tree().get_current_scene().get_node("Player/Player2")  # Adjust path if necessary
		if player:
			print("Player node found:", player)
			if player.has_method("take_damage"):
				print("Calling player.take_damage()")
				player.take_damage()
			else:
				print("Player node does not have take_damage method")
		else:
			print("Player node not found")

func update_hp_label(HP, playerName):
	HUD.update_hp_label(HP, playerName)  # Reset HP display

func on_player_death(playerName):
	print("Player has died!")  # Debugging line
	#anim.play("Damage")  # Optional: Play damage or death animation
	# Restart the level or show a game-over screen
	if playerHP <= 0 and player2HP <= 0:
		playerHP = 100
		player2HP = 100
		update_hp_label(100, "Player")
		update_hp_label(100, "Player2")
		HUD.dmg_sound()
		get_tree().reload_current_scene()
