extends CanvasLayer

@onready var hp_label1 = $PlayerHPLabel
@onready var hp_label2 = $Player2HPLabel
@onready var score_label = $ScoreLabel


func update_hp_label(hp, playerName):
	if playerName == "Player":
		hp_label1.text = "Player 1 HP: " + str(hp)  # Update the label text
	else:
		hp_label2.text = "Player 2 HP: " + str(hp)  # Update the label text
		
func update_score(playerName):
	if playerName == "Player":
		Global.playerScore += 1
	else:
		Global.player2Score += 1
	score_label.text = """SCORE
	Player 1: """+str(Global.playerScore)+"""
	Player 2: """+str(Global.player2Score)
	

func clear_label():
	hp_label1.text = ""
	hp_label2.text = ""
	score_label.text = ""

func dmg_sound():
	$DamageSound.play()
	
func level_sound():
	$NextLevel.play()

func congrats_sound():
	$Congrats.play()
