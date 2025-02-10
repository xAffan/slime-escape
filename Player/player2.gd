extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const DEATH_Y_THRESHOLD = 1000.0  # The Y position below which the player dies
const LEVEL_END_X = 1152  # Adjust this to the X position of the level's end

@onready var anim = get_node("AnimatedSprite2D")
var is_taking_damage = false  # Flag to control damage animation

func _ready() -> void:
	anim.play("Idle")

func _physics_process(delta: float) -> void:
	# Check if player has fallen below the death threshold
	if position.y > DEATH_Y_THRESHOLD and Global.player2HP > 0:
		die()
		return

	# If taking damage, don't update other animations or movement
	if is_taking_damage:
		velocity = Vector2.ZERO  # Stop all movement during damage
		return

	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("player2_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim.play("Jump")  # Play jump animation

	# Get input direction and handle movement
	var direction := Input.get_axis("player2_left", "player2_right")
	if direction != 0:
		velocity.x = direction * SPEED
		anim.play("Run")  # Play run animation
		anim.flip_h = direction < 0  # Flip sprite if moving left
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		# Play idle animation only when on the ground and not jumping
		if is_on_floor() and velocity.y == 0:
			anim.play("Idle")

	move_and_slide()

	# Check if the player has crossed the level's end boundary
	if position.x > LEVEL_END_X:
		level_complete()

func take_damage() -> void:
	if is_taking_damage:
		return  # Prevent re-triggering damage animation

	is_taking_damage = true
	anim.play("Damage")  # Play damage animation

	print("Playing Damage animation")  # Debugging line

	# Wait for the damage animation duration (adjust as needed)
	await get_tree().create_timer(0.5).timeout
	is_taking_damage = false  # Allow other animations to resume

	print("Damage animation completed")  # Debugging line

	# Transition back to the appropriate animation
	if is_on_floor():
		if velocity.x != 0:
			anim.play("Run")
		else:
			anim.play("Idle")
	else:
		anim.play("Jump")
		
	if Global.player2HP <= 0:
		position.y = -9999
		position.x = -9999

func die() -> void:
	anim.play("Damage")  # Optional: Play damage or death animation
	Global.player2HP = 0
	Global.update_hp_label(0, "Player2")
	Global.on_player_death("Player2")  # Assuming a separate function for player 2 death

func level_complete():
	Global.LEVEL += 1
	HUD.update_score("Player2")
	print("Level Complete! Progressing to "+str(Global.LEVEL))
	if Global.LEVEL >= 11:
		print("Blud did it")
		HUD.clear_label()
		HUD.congrats_sound()
		if Global.playerScore > Global.player2Score:
			get_tree().change_scene_to_file('res://Levels/win1.tscn')
		elif Global.player2Score > Global.playerScore:
			get_tree().change_scene_to_file('res://Levels/win2.tscn')
		else:
			get_tree().change_scene_to_file('res://Levels/tied.tscn')
		
	else:
		Global.playerHP = 100
		Global.update_hp_label(100, "Player")
		HUD.level_sound()
		get_tree().change_scene_to_file('res://Levels/level'+str(Global.LEVEL)+'.tscn')
