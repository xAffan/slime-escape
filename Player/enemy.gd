extends CharacterBody2D

var SPEED = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var player2
var chase = false
var damage_interval = 0.5  # Time (in seconds) between each damage instance
var is_damaging = false  # Tracks if the player is being damaged
var damage_timer: Timer  # Declare the timer variable

@onready var anim = $AnimatedSprite2D  # Reference to the AnimatedSprite2D node

func _ready():
	# Add a timer for dealing damage
	damage_timer = Timer.new()
	damage_timer.set_wait_time(damage_interval)
	damage_timer.set_one_shot(false)
	damage_timer.connect("timeout", Callable(self, "_on_damage_timer_timeout"))
	add_child(damage_timer)

	anim.play("Idle")  # Start with Idle animation

var target_player_name: String = ""  # Stores the name of the player being damaged

func _on_player_damage_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "Player2":
		is_damaging = true
		target_player_name = body.name  # Store the name of the player
		anim.play("Attack")  # Play attack animation
		damage_timer.start()  # Start the damage timer for continuous damage

func _on_player_damage_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body.name == "Player2":
		is_damaging = false
		damage_timer.stop()  # Stop the damage timer
		target_player_name = ""  # Clear the target player name
		anim.play("Idle")  # Return to idle animation when player exits range

func _on_damage_timer_timeout():
	if is_damaging:
		Global.take_damage(9 * Global.LEVEL, target_player_name)  # Pass the player's name to take_damage
		apply_knockback_to_player()

func apply_knockback_to_player():
	var target = null
	if target_player_name == "Player":
		target = get_node_or_null("../../Player/Player")
	elif target_player_name == "Player2":
		target = get_node_or_null("../../Player2/Player2")
	
	if target:
		var direction = (target.position - position).normalized()  # Direction away from the enemy
		var knockback_force = Vector2(300, -200)  # Adjust the X and Y knockback forces as needed

		# Apply knockback in the correct horizontal direction
		target.velocity.x += knockback_force.x if direction.x > 0 else -knockback_force.x
		target.velocity.y += knockback_force.y  # Push upwards slightly
		print("Knockback applied to target: ", target.velocity)


func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta

	if chase:

		var nearest_target = null
		var nearest_distance = INF

		# Check distances to both players
		if player:
			var distance_to_player = position.distance_to(player.position)
			if distance_to_player < nearest_distance:
				nearest_target = player
				nearest_distance = distance_to_player

		if player2:
			var distance_to_player2 = position.distance_to(player2.position)
			if distance_to_player2 < nearest_distance:
				nearest_target = player2
				nearest_distance = distance_to_player2

		# Chase the nearest target
		if nearest_target:
			var direction = nearest_target.position - position
			direction.y = 0  # Ignore vertical movement
			
			if direction.length() > 1:  # Avoid small distance jitter
				velocity.x = direction.normalized().x * SPEED
				if not is_damaging:
					anim.play("Run")  # Play run animation when chasing

				# Flip the sprite based on direction
				anim.flip_h = direction.x > 0  # Flip when moving right
			else:
				velocity.x = 0  # Stop moving if too close
				if not is_damaging:
					anim.play("Idle")  # Play idle animation when close
		else:
			velocity.x = 0  # No valid target
			anim.play("Idle")
	else:
		velocity.x = 0  # Not chasing
		if not is_damaging:
			anim.play("Idle")  # Play idle animation when not chasing

	# Move the enemy
	move_and_slide()


func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true
		player = body  # Cache the player reference
	elif body.name == "Player2":
		player2 = body
		chase = true

func _on_player_detection_body_exited(body):
	if body.name == "Player":
		player = null  # Clear the player reference
	elif body.name == "Player2":
		player2 = null
	if player == null and player2 == null:
		chase = false
