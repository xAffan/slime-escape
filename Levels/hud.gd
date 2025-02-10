extends CanvasLayer

@onready var hp_label = $PlayerHPLabel

func update_hp_label(hp):
	hp_label.text = "HP: " + str(hp)  # Update the label text

func clear_label():
	hp_label.text = ""

func dmg_sound():
	$DamageSound.play()
	
func level_sound():
	$NextLevel.play()

func congrats_sound():
	$Congrats.play()
