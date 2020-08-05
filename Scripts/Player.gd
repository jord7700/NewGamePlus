extends KinematicBody2D


# Declare member variables here.
const FLOOR_NORMAL = Vector2.UP
const SLOPE_THRESHOLD = deg2rad(45)
const SLOPE_BOOST = 1
const GRAVITY = 240

var velocity = Vector2(0, 0)
var walkingSpeed = 450
var walkingMod = 0

var direction = Vector2.ZERO
var timeInAir = 0
var inAir = true
var jumpUsed = true

# Called when the node enters the scene tree for the first time.
func _ready():
	print("player loaded")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_input()
	check_anim()

func _physics_process(delta):	
	#handle movement
	if inAir == true:
		timeInAir += delta
		
	move_and_slide_with_snap(velocity, Vector2(0, 10.0), FLOOR_NORMAL, true, 4, SLOPE_THRESHOLD)
	if velocity.y <= 550:
		velocity.y += GRAVITY * timeInAir
	#end handle movement

func _on_Area2D_body_entered(body):	
	inAir = false
	timeInAir = 0
	var slope_angle = abs(body.get_rotation_degrees())
	#print("slope angle: " , slope_angle)
	if slope_angle >= 0 and slope_angle < rad2deg(SLOPE_THRESHOLD):
		if velocity.y >= 0:
			jumpUsed = false
		if walkingMod <= 50 and slope_angle > 0:
			walkingMod += 300 / slope_angle

func _on_Area2D_body_exited(body):
	inAir = true


func check_input():
	if Input.is_action_pressed("Move_Right"):
		velocity.x = walkingSpeed + walkingMod
	elif Input.is_action_pressed("Move_Left"):
		velocity.x = -walkingSpeed - walkingMod
	if Input.is_action_just_released("Move_Right"):
		velocity.x = 0
		walkingMod = 0
	elif Input.is_action_just_released("Move_Left"):
		velocity.x = 0
		walkingMod = 0
	if Input.is_action_just_pressed("Slide_Right"):
		walkingMod = 750		
	elif Input.is_action_just_released("Slide_Right"):
		walkingMod = 0
	if Input.is_action_just_pressed("Slide_Left"):		
		walkingMod = 750
	elif Input.is_action_just_released("Slide_Left"):
		walkingMod = 0
	if Input.is_action_just_pressed("ui_select") and jumpUsed == false:
		jumpUsed = true
		velocity.y = -1200

func check_anim():
	if velocity.x > 0 and velocity.x < 451:
		$AnimatedSprite.play("right")
	elif velocity.x <= 0 and velocity.x > -451:
		$AnimatedSprite.play("left")
	elif velocity.x > 451:
		$AnimatedSprite.play("dash_right")
	elif velocity.x < -451:
		$AnimatedSprite.play("dash_left")
