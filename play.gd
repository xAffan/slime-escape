extends Button

func _on_pressed() -> void:
	HUD.update_hp_label(100, "Player")
	HUD.update_hp_label(100, "Player2")
	HUD.update_score("Player")
	HUD.update_score("Player2")
	get_tree().change_scene_to_file("res://Levels/level1.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
