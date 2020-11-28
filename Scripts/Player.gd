extends KinematicBody2D

# Hi Jord <3

# Declare member variables here.
const FLOOR_NORMAL = Vector2.UP
const SLOPE_THRESHOLD = deg2rad(42)
const GRAVITY = 3100
const WALKINGSPEED = 685

#Movement related
var walkingMod = 1
var xSpeed = 0
var velocity = Vector2(0, 0)
var direction = Vector2.ZERO
var facingDirection = "left"
#Movement bools
var inAir = true
var isDashing = false
var isCrouching = false
var dashUsed = false
var jumpUsed = true

#time and timers
var timeInAir = 0

#weird stuff
var pause = false

#predefined functions and node calls
# Called when the node enters the scene tree for the first time.
func _ready():
	print("player loaded")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_input()

func _physics_process(delta):
	#handle movement
	velocity.x = xSpeed
	if inAir == true:
		timeInAir = delta
		#print(timeInAir)
	move_and_slide_with_snap(
		velocity, 
		Vector2(0, 10), 
		FLOOR_NORMAL, 
		true, 
		4, 
		SLOPE_THRESHOLD
		)
	if velocity.y <= 1200:
		velocity.y += GRAVITY * timeInAir
	#end handle movement

func _on_Area2D_body_entered(body):
	inAir = false
	timeInAir = 0
	velocity.y = 10
	var slope_angle = abs(body.get_rotation_degrees())
	if slope_angle >= 0 and slope_angle < rad2deg(SLOPE_THRESHOLD):
		if velocity.y >= 0:
			jumpUsed = false
		if walkingMod <= 50 and slope_angle > 0:
			walkingMod += 1 / slope_angle

func _on_Area2D_body_exited(body):
	inAir = true

func _on_DashTimer_timeout():
	xSpeed = 0
	if facingDirection == "right":
		$AnimatedSprite.play("right")
	elif facingDirection == "left":
		$AnimatedSprite.play("left")

func _on_DashCoolDownTimer_timeout():
	while(inAir == true):
		yield(get_tree(), "idle_frame")
	$DashCoolDownTimer.set_wait_time(0.37)
	dashUsed = false

#custom functions
func check_input():
	if pause != true:
		if Input.is_action_just_pressed("ui_cancel"):
			pause = true
		if $DashTimer.is_stopped():
			checkAttack()
			checkWalk()
			checkCrouch()
			checkSlide()
			checkSprint()
		if Input.is_action_just_pressed("ui_select") and jumpUsed == false:
			jumpUsed = true
			velocity.y = -1420

func checkAttack():
	if Input.is_action_just_pressed("Light_Attack"):
		print("attack")
		$AttackArea2D/CollisionShape2D.disabled = false
		yield(get_tree().create_timer(0.25), "timeout")
		$AttackArea2D/CollisionShape2D.disabled = true

func checkWalk():
	if Input.is_action_pressed("Move_Right"):
			xSpeed = WALKINGSPEED * walkingMod
			$AnimatedSprite.play("right")
			$AttackArea2D.position = Vector2(30, 0)
			facingDirection = "right"
	elif Input.is_action_pressed("Move_Left"):
			xSpeed = -WALKINGSPEED * walkingMod
			$AnimatedSprite.play("left")
			$AttackArea2D.position = Vector2(-30, 0)
			facingDirection = "left"
	elif Input.is_action_just_released("Move_Right"):
			xSpeed = 0
	elif Input.is_action_just_released("Move_Left"):
			xSpeed = 0

func checkCrouch():
	if Input.is_action_pressed("Crouch"):
		walkingMod = 0.2
		if inAir == false:
			set_position(Vector2(get_position().x, get_position().y + 6.0))
		$PlayerCollision2D.set_scale(Vector2(1, 0.5))
		$PlayerArea2D/CollisionShape2D.set_scale(Vector2(1, 0.5))
		isCrouching = true
		if facingDirection == "left":
			$AnimatedSprite.play("crouch_left")
		else:
			$AnimatedSprite.play("crouch_right")
	elif Input.is_action_just_released("Crouch"):
		walkingMod = 1
		$PlayerCollision2D.set_scale(Vector2(1, 1))
		$PlayerArea2D/CollisionShape2D.set_scale(Vector2(1, 1))
		isCrouching = false
		if facingDirection == "left":
			$AnimatedSprite.play("left")
		else:
			$AnimatedSprite.play("right")

func checkSlide():
	if Input.is_action_just_pressed("Slide_Right") and dashUsed == false:
		if isCrouching == false:
			if facingDirection == "right":
				$AnimatedSprite.play("dash_right")
				xSpeed = 2900
				$DashTimer.start()
				dashUsed = true
				$DashCoolDownTimer.start()
			else:
				if inAir == false:
					xSpeed = 2900
					$BackDashTimer.start()
					dashUsed = true
					$DashCoolDownTimer.start()
		#roll right
		elif isCrouching == true:
			$AnimatedSprite.play("roll")
			if facingDirection == "right":
				xSpeed = 1300
				$DashTimer.start()
				dashUsed = true
				$DashCoolDownTimer.start()
			else:
				xSpeed = 1300
				$DashTimer.start()
				dashUsed = true
				$DashCoolDownTimer.start()

	elif Input.is_action_just_pressed("Slide_Left") and dashUsed == false:
		if isCrouching == false:
			if facingDirection == "left" and isCrouching == false:
				$AnimatedSprite.play("dash_left")
				xSpeed = -2900
				$DashTimer.start()
				dashUsed = true
				$DashCoolDownTimer.start()
			else:
				if inAir == false:
					xSpeed = -2900
					$BackDashTimer.start()
					dashUsed = true
					$DashCoolDownTimer.start()
		#roll left
		elif isCrouching == true:
			$AnimatedSprite.play("roll")
			if facingDirection == "left" and isCrouching == false:
				xSpeed = -1300
				$DashTimer.start()
				dashUsed = true
				$DashCoolDownTimer.start(0.25)
			else:
				xSpeed = -1300
				$DashTimer.start()
				dashUsed = true
				$DashCoolDownTimer.start(0.25)

func checkSprint():
	if Input.is_action_pressed("Sprint"):
		walkingMod = 2
	elif Input.is_action_just_released("Sprint"):
		walkingMod = 1


func _on_AttackArea2D_area_entered(area):
	print("Hit!")
	area.get_owner().damaged(10)
