@tool
extends StaticBody3D

const vertices = [
	Vector3(0, 0, 0), #0
	Vector3(Global.BLOCK_SIZE, 0, 0), #1
	Vector3(0, Global.BLOCK_SIZE, 0), #2
	Vector3(Global.BLOCK_SIZE, Global.BLOCK_SIZE, 0), #3
	Vector3(0, 0, Global.BLOCK_SIZE), #4
	Vector3(Global.BLOCK_SIZE, 0, 1), #5
	Vector3(0, Global.BLOCK_SIZE, Global.BLOCK_SIZE), #6
	Vector3(Global.BLOCK_SIZE, Global.BLOCK_SIZE, Global.BLOCK_SIZE)  #7
]

const TOP = [2, 3, 7, 6]
const BOTTOM = [0, 4, 5, 1]
const LEFT = [6, 4, 0, 2]
const RIGHT = [3, 1, 5, 7]
const FRONT = [7, 5, 4, 6]
const BACK = [2, 0, 1, 3]

var blocks = []

var st = SurfaceTool.new()
var mesh = null
var meshInstance = null

var chunk_position: Vector2
func set_chunk_position(x, y):
	chunk_position = Vector2(x, y)
	position = Vector3(x * Global.BLOCK_SIZE, 0, y * Global.BLOCK_SIZE) * Global.DIMENSION
	
	self.visible = false

var material = preload("res://textures/new_standard_material_3d.tres")

@export var noise = FastNoiseLite.new()

func _ready():
	generate()
	update()

func generate():
	blocks = []
	blocks.resize(Global.DIMENSION.x)
	for x in range(0, Global.DIMENSION.x):
		blocks[x] = []
		blocks[x].resize(Global.DIMENSION.y)
		for y in range(0, Global.DIMENSION.y):
			blocks[x][y] = []
			blocks[x][y].resize(Global.DIMENSION.z)
			for z in range(0, Global.DIMENSION.z):
				var global_pos = chunk_position * Vector2(Global.DIMENSION.x, Global.DIMENSION.z) + Vector2(x, z)
				
				var height = int((noise.get_noise_2dv(global_pos) + 1)/2 * Global.DIMENSION.y)
				
				var block = Global.AIR
				if y < height/2:
					block = Global.STONE
				elif y < height:
					block = Global.DIRT
				elif y == height:
					block = Global.GRASS
				blocks[x][y][z] = block

func update():
	if meshInstance != null:
		meshInstance.call_deferred("queue_free")
		meshInstance = null

	mesh = ArrayMesh.new()
	meshInstance = MeshInstance3D.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)

	for x in Global.DIMENSION.x:
		for y in Global.DIMENSION.y:
			for z in Global.DIMENSION.z:
				create_block(x * Global.BLOCK_SIZE, y * Global.BLOCK_SIZE, z * Global.BLOCK_SIZE)

	st.generate_normals(false)
	st.set_material(material)
	st.commit(mesh)
	meshInstance.set_mesh(mesh)

	add_child(meshInstance)
	meshInstance.create_trimesh_collision()
	
	self.visible = true

func check_transparent(x, y, z):
	if x >= 0 and x < Global.DIMENSION.x and y >= 0 and y < Global.DIMENSION.y and z >= 0 and z < Global.DIMENSION.z:
		return not Global.types[blocks[x][y][z]][Global.SOLID]
	return true

func create_block(x, y, z):
	var block = blocks[x][y][z]
	if block == Global.AIR:
		return

	var blockInfo = Global.types[block]

	if check_transparent(x, y+1, z):
		create_face(TOP, x, y, z, blockInfo[Global.TOP])
	if check_transparent(x, y-1, z):
		create_face(BOTTOM, x, y, z, blockInfo[Global.BOTTOM])
	if check_transparent(x-1, y, z):
		create_face(LEFT, x, y, z, blockInfo[Global.LEFT])
	if check_transparent(x+1, y, z):
		create_face(RIGHT, x, y, z, blockInfo[Global.RIGHT])
	if check_transparent(x, y, z+1):
		create_face(FRONT, x, y, z, blockInfo[Global.FRONT])
	if check_transparent(x, y, z-1):
		create_face(BACK, x, y, z, blockInfo[Global.BACK])

func create_face(side, x, y, z, texture_atlas_offset):
	var offset = Vector3(x, y, z)
	var a = vertices[side[0]] + offset
	var b = vertices[side[1]] + offset 
	var c = vertices[side[2]] + offset
	var d = vertices[side[3]] + offset

	var uv_offset = texture_atlas_offset / Global.TEXTURE_ATLAS_SIZE
	var height = 1.0 / Global.TEXTURE_ATLAS_SIZE.y
	var width = 1.0 / Global.TEXTURE_ATLAS_SIZE.x

	var uv_a = uv_offset + Vector2(0, 0)
	var uv_b = uv_offset + Vector2(0, height)
	var uv_c = uv_offset + Vector2(width, height)
	var uv_d = uv_offset + Vector2(width, 0)

	st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]))
	st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]))






