extends KinematicBody2D


# Declare member variables here. Examples:
var health = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func damaged(var damage):
	health -= damage
	if(health <= 0):
		print("Dummy DEAD")
