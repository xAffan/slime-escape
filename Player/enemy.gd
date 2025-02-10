extends CharacterBody2D

var SPEED = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
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

func _on_player_damage_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_damaging = true
		anim.play("Attack")  # Play attack animation
		damage_timer.start()  # Start the damage timer for continuous damage

func _on_player_damage_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_damaging = false
		damage_timer.stop()  # Stop the damage timer
		anim.play("Idle")  # Return to idle animation when player exits range

func _on_damage_timer_timeout():
	if is_damaging and player:
		Global.take_damage(3*Global.LEVEL)  # Deal 3 damage to the player
		apply_knockback_to_player()

func apply_knockback_to_player():
	if player:
		var direction = (player.position - position).normalized()  # Direction away from the enemy
		var knockback_force = Vector2(300, -200)  # Adjust the X and Y knockback forces as needed

		# Apply knockback in the correct horizontal direction
		player.velocity.x += knockback_force.x if direction.x > 0 else -knockback_force.x
		player.velocity.y += knockback_force.y  # Push upwards slightly
		print("Knockback applied to player: ", player.velocity)



func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta

	if chase:
		if not player:
			# Ensure player reference is valid
			player = get_node_or_null("../../Player/Player")
		
		if player:
			# Calculate the horizontal direction only
			var direction = player.position - position
			direction.y = 0  # Ignore vertical movement
			
			if direction.length() > 1:  # Avoid small distance jitter
				velocity.x = direction.normalized().x * SPEED
				if not is_damaging:
					anim.play("Run")  # Play run animation when chasing the player

					# Flip the sprite based on direction
					anim.flip_h = direction.x > 0  # Flip when moving left
			else:
				velocity.x = 0  # Stop moving if too close
				if not is_damaging:
					anim.play("Idle")  # Play idle animation when close to the player
	else:
		velocity.x = 0
		if not is_damaging:
			anim.play("Idle")  # Play idle animation when not chasing

	# Move the enemy
	move_and_slide()

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true
		player = body  # Cache the player reference

func _on_player_detection_body_exited(body):
	if body.name == "Player":
		chase = false
		player = null  # Clear the player reference
