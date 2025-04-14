class_name Asteroid extends Area2D

signal exploded(pos, size, points)

var movement_vector := Vector2(0, -1)
var speed := 50.0
@export var asteroid_size := AsteroidSize.LARGE
@export var shape := Shape.TRIANGLE

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@export var points: int = 0

enum AsteroidSize {
	LARGE,
	MEDIUM,
	SMALL
}

enum Shape {
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
			points = 100
		AsteroidSize.MEDIUM:
			speed = randf_range(100.0, 150.0)
			shape_size = randf_range(20.0, 40.0)
			points = 50
		AsteroidSize.SMALL:
			speed = randf_range(100.0, 200.0)
			shape_size = randf_range(7.0, 10.0)
			points = 25
	ShapeBuilder.generate_random_shape(shape_size, polygon_2d)
	collision_polygon_2d.polygon = polygon_2d.polygon
			

	
func _physics_process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	var margin = ShapeBuilder.get_max_shape_radius(polygon_2d)
	var screen_size = get_viewport_rect().size
	
	if global_position.y + margin < 0:
		global_position.y = screen_size.y + margin
	elif global_position.y - margin > screen_size.y:
		global_position.y = -margin
		
	if global_position.x + margin < 0:
		global_position.x = screen_size.x + margin
	elif global_position.x - margin > screen_size.x:
		global_position.x = -margin

func explode() -> void:
	emit_signal("exploded", global_position, asteroid_size, points)
	queue_free()
	
	
