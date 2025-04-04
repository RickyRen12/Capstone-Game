extends RigidBody2D

var size

func make_room(_pos, _size):
	position = _pos
	size = _size
	var s = RectangleShape2D.new()
	s.extents = size
	s.custom_solver_bias = 0.75
	$CollisionShape2D.shape = s
