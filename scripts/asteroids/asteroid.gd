class_name Asteroid extends Area2D

signal exploded(pos, size)

var movement_vector := Vector2(0, -1)
var speed := 50.0
@export var asteroid_size := AsteroidSize.LARGE
@export var shape := AsteroidShape.TRIANGLE

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

enum AsteroidSize {
	LARGE,
	MEDIUM,
	SMALL
}

enum AsteroidShape {
	TRIANGLE,
	CIRCLE,
	SQUARE
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation = randf_range(0, 2 * PI)
	#0 -> square, 1-> triangle, 2-> circle
	var shape_size = null
	match asteroid_size:
		AsteroidSize.LARGE:
			speed = randf_range(50.0, 100.0)
			shape_size = randf_range(45.0, 60.0)
		AsteroidSize.MEDIUM:
			speed = randf_range(100.0, 150.0)
			shape_size = randf_range(20.0, 40.0)
		AsteroidSize.SMALL:
			speed = randf_range(100.0, 200.0)
			shape_size = randf_range(7.0, 10.0)
	print(str(shape_size))
	generate_random_shape(shape_size)
			

	
func _physics_process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	var margin = get_max_shape_radius()
	var screen_size = get_viewport_rect().size
	
	if global_position.y + margin < 0:
		global_position.y = screen_size.y + margin
	elif global_position.y - margin > screen_size.y:
		global_position.y = -margin
		
	if global_position.x + margin < 0:
		global_position.x = screen_size.x + margin
	elif global_position.x - margin > screen_size.x:
		global_position.x = -margin
	
func generate_random_shape(size: float):
	var asteroid_shape = AsteroidShape.values().pick_random() as AsteroidShape
	
	match asteroid_shape:
		AsteroidShape.TRIANGLE:
			polygon_2d.polygon = [
				Vector2(0, -size),
				Vector2(size, size),
				Vector2(-size, size)
			] # roughly centers triangle
		AsteroidShape.SQUARE:
			polygon_2d.polygon = [
				Vector2(-size, -size),
				Vector2(size, -size),
				Vector2(size, size),
				Vector2(-size, size)
			]
		AsteroidShape.CIRCLE:
			polygon_2d.polygon = draw_circle_polygon(size, 32)
	
	collision_polygon_2d.set_deferred("polygon", polygon_2d.polygon)

func explode() -> void:
	emit_signal("exploded", global_position, asteroid_size)
	queue_free()
	

func draw_circle_polygon(radius: float, sides: int) -> PackedVector2Array:
	var points = PackedVector2Array()
	for i in sides:
		var angle = (PI * 2) * i / sides
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points
#gets furtheset vertex from center of shape
func get_max_shape_radius() -> float:
	var max_distance := 0.0
	for point in polygon_2d.polygon:
		max_distance = max(max_distance, point.length())
	return max_distance
