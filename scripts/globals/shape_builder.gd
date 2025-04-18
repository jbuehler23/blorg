extends Node

enum Type {
	TRIANGLE,
	CIRCLE,
	SQUARE
}

func generate_random_shape(size: float, polygon_2d: Polygon2D) -> Type:
	var asteroid_shape = Type.values().pick_random() as Type
	
	match asteroid_shape:
		Type.TRIANGLE:
			generate_triangle(size, polygon_2d)
		Type.SQUARE:
			generate_square(size, polygon_2d)
		Type.CIRCLE:
			generate_circle(size, polygon_2d)
	return asteroid_shape

func draw_circle_polygon(radius: float, sides: int) -> PackedVector2Array:
	var points = PackedVector2Array()
	for i in sides:
		var angle = (PI * 2) * i / sides
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points
	
func get_max_shape_radius(polygon_2d: Polygon2D) -> float:
	var max_distance := 0.0
	for point in polygon_2d.polygon:
		max_distance = max(max_distance, point.length())
	return max_distance

func generate_circle(size: float, polygon_2d: Polygon2D) -> void:
	polygon_2d.polygon = draw_circle_polygon(size, 32)
	polygon_2d.color = Color.html("#d17a8b")

func generate_triangle(size: float, polygon_2d: Polygon2D) -> void:
	polygon_2d.polygon = [
				Vector2(0, -size),
				Vector2(size, size),
				Vector2(-size, size)
			] # roughly centers triangle
	polygon_2d.color = Color.html("#973b39")
	
func generate_square(size: float, polygon_2d: Polygon2D) -> void:
	polygon_2d.polygon = [
				Vector2(-size, -size),
				Vector2(size, -size),
				Vector2(size, size),
				Vector2(-size, size)
			]
	polygon_2d.color = Color.html("#c96842")
