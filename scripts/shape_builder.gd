extends Node

func draw_circle_polygon(points_total: int, radius: float, color: Color) -> Polygon2D:
	var points = PackedVector2Array()
	for i in range(points_total + 1):
		var point = deg_to_rad(i * 360.0 / points_total - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * radius)
	var polygon_2d = Polygon2D.new()
	polygon_2d.draw_colored_polygon(points, color)
	return polygon_2d
