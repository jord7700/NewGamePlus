extends Area2D


var playerVars

# Called when the node enters the scene tree for the first time.
func _ready():
	playerVars = get_node("/root/PlayerVars")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(deg2rad(delta * 450))
#	pass



func _on_Point_body_entered(body):
	playerVars.points += 1
	print("Points: ", playerVars.points)
	queue_free()
