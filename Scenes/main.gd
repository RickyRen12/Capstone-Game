extends Node2D
@onready var player = PlayerManager.get_player()

# Called when the node enters the scene tree for the first time.
func _ready():
	if player == null:
		print("nah youre cooked")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
