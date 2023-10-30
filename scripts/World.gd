extends Node3D

var chunk_scene = preload("res://scenes/chunk.tscn")

var render_distance = 5
@onready var chunks = $Chunks
@onready var player = $Player

var load_thread = Thread.new()
var thread_start = Callable(self, "_thread_process")
func _ready():
	for x in range(0, render_distance):
		for z in range(0, render_distance):
			var chunk = chunk_scene.instantiate()
			chunk.position = Vector3(x * 16, 0, z * 16) # chunks are 16x64x16, so put them 16 blocks apart on the x and z axis
			chunks.add_child(chunk)
	load_thread.start(thread_start)
