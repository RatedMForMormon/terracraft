extends Node3D

func _ready():
	self.top_level = true

func _process(_delta):
	position = $"..".position
