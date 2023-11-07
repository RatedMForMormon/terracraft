extends Node3D

var chunk_scene = preload("res://scenes/chunk.tscn")

var render_distance = 5
@onready var chunks = $Chunks
@onready var player = $player
var load_thread: Thread
func _ready():
	for x in range(0, render_distance):
		for z in range(0, render_distance):
			var chunk = chunk_scene.instantiate()
			chunk.set_chunk_position(x, z)
			chunks.add_child(chunk)
	load_thread = Thread.new()
#	print_debug("starting thread")
	load_thread.start(_thread_process.bind("yo mama"), Thread.PRIORITY_HIGH)

func _thread_process(userdata): # make this function duplicateable so I can run 5-6 at a time
	
	while true:
		for chunk in chunks.get_children():
			var chunkx = chunk.chunk_position.x
			var chunkz = chunk.chunk_position.y
			
			var playerx = floor(player.position.x / Global.DIMENSION.x)
			var playerz = floor(player.position.z / Global.DIMENSION.z)
			
			var new_x = posmod(chunkx - playerx + render_distance/2, render_distance) + playerx - render_distance/2
			var new_z = posmod(chunkz - playerz + render_distance/2, render_distance) + playerz - render_distance/2
			
			if new_x != chunkx or new_z != chunkz:
				chunk.set_chunk_position(int(new_x), int(new_z))
				chunk.generate()
				chunk.update()

func _exit_tree():
	load_thread.wait_to_finish()
