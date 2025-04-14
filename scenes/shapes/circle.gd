@tool
extends Polygon2D

@export var radius: float = 128.0

func _draw() -> void:
	draw_circle(Vector2(0,0), radius, Color.WHITE)
