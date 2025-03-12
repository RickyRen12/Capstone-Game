extends CharacterBody2D

var size

func make_room(_pos, _size):
	position = _pos
	size = _size
	var s = RectangleShape2D.new()
	s.extents = size
