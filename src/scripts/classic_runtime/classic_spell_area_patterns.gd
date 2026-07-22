class_name ClassicSpellAreaPatterns
extends RefCounted

# Data AD stores eighteen 7x7 masks. Coordinates here are relative to the
# mask's center and preserve the source file's row-major orientation.
const PATTERNS: Array[Array] = [
	[Vector2i(0, 0)],
	[Vector2i(0, 0), Vector2i(0, 1)],
	[Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
	[
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
	],
	[
		Vector2i(0, -2),
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(0, 2),
	],
	[
		Vector2i(0, -3),
		Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2),
		Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
		Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2),
		Vector2i(0, 3),
	],
	[
		Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3),
		Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2),
		Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
		Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2),
		Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3),
	],
	[
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0), Vector2i(1, 0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
	],
	[
		Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2),
		Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
		Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2),
	],
	[
		Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
	],
	[
		Vector2i(3, -3), Vector2i(2, -2), Vector2i(3, -2), Vector2i(1, -1), Vector2i(2, -1),
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1),
		Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(-3, 3), Vector2i(-2, 3),
	],
	[
		Vector2i(0, -3), Vector2i(1, -3), Vector2i(0, -2), Vector2i(1, -2),
		Vector2i(0, -1), Vector2i(1, -1), Vector2i(0, 0), Vector2i(1, 0),
		Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2),
		Vector2i(0, 3), Vector2i(1, 3),
	],
	[
		Vector2i(-3, -3), Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(-2, -1), Vector2i(-1, -1),
		Vector2i(-1, 0), Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(1, 2), Vector2i(2, 2), Vector2i(2, 3), Vector2i(3, 3),
	],
	[
		Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3),
		Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2),
		Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(2, -1), Vector2i(3, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(2, 1), Vector2i(3, 1),
		Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2),
		Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3),
	],
	[Vector2i(0, 0)],
	[Vector2i(0, -1), Vector2i(0, 0)],
	[Vector2i(-1, 0), Vector2i(0, 0)],
	[Vector2i(-1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(0, 0)],
]


static func pattern(shape: int) -> Array[Vector2i]:
	if shape < 1 or shape > PATTERNS.size():
		return [Vector2i.ZERO]
	var result: Array[Vector2i] = []
	for point: Vector2i in PATTERNS[shape - 1]:
		result.append(point)
	return result
