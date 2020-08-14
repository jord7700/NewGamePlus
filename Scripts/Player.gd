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
var dashUsed = false
var jumpUsed = true

#time and timers
var timeInAir = 0
var dashFrames = 0

#predefined functions and node calls
# Called when the node enters the scene tree for the first time.
func _ready():
	print("player loaded")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	check_input()
	if dashFrames > 0:
		dashFrames -= 1
		if dashFrames == 0:
			xSpeed = 0

func _physics_process(delta):
	#handle movement
	velocity.x = xSpeed
	if inAir == true:
		timeInAir = delta
		print(timeInAir)
	move_and_slide_with_snap(velocity, Vector2(0, 10), FLOOR_NORMAL, true, 4, SLOPE_THRESHOLD)
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
	dashUsed = false

#custom functions
func check_input():
	if $DashTimer.is_stopped():
		if Input.is_action_pressed("Move_Right"):
			xSpeed = WALKINGSPEED * walkingMod
			$AnimatedSprite.play("right")
			facingDirection = "right"
		elif Input.is_action_pressed("Move_Left"):
			xSpeed = -WALKINGSPEED * walkingMod
			$AnimatedSprite.play("left")
			facingDirection = "left"
		if Input.is_action_just_released("Move_Right"):
			xSpeed = 0			
		elif Input.is_action_just_released("Move_Left"):
			xSpeed = 0
		if Input.is_action_just_pressed("Slide_Right"):
			if dashUsed == false:
				$AnimatedSprite.play("dash_right")
				xSpeed = 2900
				$DashTimer.start()
				dashUsed = true
				$DashCoolDownTimer.start()
		if Input.is_action_just_pressed("Slide_Left"):
			if dashUsed == false:
				$AnimatedSprite.play("dash_left")
				xSpeed = -2900
				$DashTimer.start()
				dashUsed = true
				$DashCoolDownTimer.start()
		if Input.is_action_pressed("Sprint"):
			walkingMod = 2
		if Input.is_action_just_released("Sprint"):
			walkingMod = 1
	if Input.is_action_just_pressed("ui_select") and jumpUsed == false:
		jumpUsed = true
		velocity.y = -1420
