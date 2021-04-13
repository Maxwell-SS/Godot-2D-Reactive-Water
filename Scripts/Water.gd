extends Node2D

onready var collision_rect = get_node("Area2D/CollisionShape2D")

var spring_entered = 1 # The spring that the object enters

var bodyX = self.position.x # Top-left x-pos
var bodyY = self.position.y # Top-right y-pos

var bodyWidth = 1950 # Horizontal span of body
var bodyHeight = 250 # Vertical span of bod

var columns = 50 # Number of springs
var columnWidth = (bodyWidth / columns) # Getting column width

var dampening = 0.025 # lower dampening = longer spring oscillation
var tension = 0.025 # Higher tension = more stiff spring and Lower tension = more loose spring
var spread = 0.25 # higher = waves spread fast & more "jello"-like
var passes = 5 # pulls on neighbors per game step. Lowest value is 1

# Arrays for springs
var height = []
var targetHeight = []
var speed = []

# Top left of spring and top right of spring
var leftDelta = []
var rightDelta = []

func _ready():
	for i in columns: # Adding main spring variables for each string in columns can be controlled
		height.insert(i, bodyHeight)
		targetHeight.insert(i, bodyHeight)
		speed.insert(i, 0)
		
		leftDelta.insert(i, 0)
		rightDelta.insert(i, 0)

func _process(_delta):
	update() # Updating _draw func every frame
	
	for i in columns:
		# Spring logic
		var displacement = (targetHeight[i] - height[i])
		speed[i] += (tension * displacement) - (dampening * speed[i])
		height[i] += speed[i]
		
		# Reset deltas each game step
		leftDelta[i] = 0
		rightDelta[i] = 0
		
		if Input.is_action_pressed("Mouse Left"):
			speed[spring_entered] -= 1
	
	for j in passes:
		for i in columns:
			if (i > 0):
				leftDelta[i] = spread * (height[i] - height[i - 1])
				speed[i - 1] += leftDelta[i]
				
			if (i < columns - 1):
				rightDelta[i] = spread * (height[i] - height[i + 1])
				speed[i + 1] += rightDelta[i]

		for i in columns:
			if (i > 0):
				height[i - 1] += leftDelta[i]
				
			if (i < columns - 1):
				height[i + 1] += rightDelta[i]

func _draw():
	# Drawing each spring 
	for i in columns:
		var _cc = columnCorners(i)
		
		var x1 = _cc[0]
		var y1 = _cc[1]
		var x2 = _cc[2]
		var y2 = _cc[3]
		
		var right_y1 = _cc[4]
		
		# Each Rect is to stacked triangles you can see them by changing one of these colors
		draw_colored_polygon(PoolVector2Array([Vector2(x1,y1), Vector2(x1, y2), Vector2(x2,y2)]), Color.deepskyblue)
		draw_colored_polygon(PoolVector2Array([Vector2(x1,y1), Vector2(x2, right_y1), Vector2(x2,y2)]), Color.deepskyblue)


# Calculating corners for specified spring
func columnCorners(var i):
	var x1 = bodyX + (i * columnWidth)
	var y1 = bodyY + targetHeight[i] - height[i]
	var x2 = x1 + columnWidth
	var y2 = bodyY + targetHeight[i]
	
	var right_y1 = y1
	
	if i < columns - 1:
		right_y1 = bodyY + targetHeight[i + 1] - height [i + 1]
		
	return [x1, y1, x2, y2, right_y1]

# func to calculate which spring to add force to 
# For objects just use area_entered and input the position.x of the object
func calculateCollisions(var xPosition):
	# getting width of each spring based on rect x size and number of springs in columns
	var spring_pixel_width = int(collision_rect.shape.extents.x) / float(columns)
	
	# gets the spring that the object enters by dividing the xPosition by spring width
	var water_column_spring = (xPosition - bodyX) / spring_pixel_width
	
	# converting to global var to that it can be used in process func and diving by 2
	spring_entered = (int(water_column_spring) / 2)
	
	print("Collided Spring: ", spring_entered)



func _on_Area2D_mouse_entered():
	# Getting mouse position
	var mousePos = get_global_mouse_position()
	
	# Calling collision
	calculateCollisions(mousePos.x)
