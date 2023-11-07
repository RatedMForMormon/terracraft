extends Camera3D

const MAX_DISTANCE = 2

func get_distance():
	
	return sqrt(pow(position.y, 2) + pow(position.z, 2))

func set_distance(value, firstperson = false):
	#somehow make the camera go diagonally at 1/4x
	# a2 + b2 = c2
	# x2 + 16x2 = value2
	# value = sqrt(17x2)
	# x = sqrt(value2/17)
	var x = sqrt(pow(value, 2)/17)
	var rise = 1
	var run = 4
	if firstperson:
		position = Vector3.ZERO
		return 0
	

	position = clamp(Vector3(0, rise * x, run * x), Vector3(0, .5, 2), Vector3(0, MAX_DISTANCE, MAX_DISTANCE*4))
	print_debug(position)
	return sqrt(pow(rise*x, 2) + pow(run*x, 2))
	
