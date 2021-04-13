extends Node2D

var targetHeight = 300
var height = 0
var tension = 0.025
var dampening = 0.025
var speed = 0

func _process(_delta):
	var displacement = (targetHeight - height)
	speed += (tension * displacement) - (dampening * speed)
	height += speed
	update()

func _draw():
	draw_line(Vector2(0.0,0.0), Vector2(0.0, 0.0 - height), Color(255, 0, 0), 5)
