class_name Laser extends Area2D

@export var projectile_speed := 500.0
@export var shape: ShapeBuilder.Type = ShapeBuilder.Type.TRIANGLE
@export var projectile_size := 10

var movement_vector := Vector2(0, -1)
@onready var collision_shape_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var polygon_2d: Polygon2D = $Polygon2D

func _ready() -> void:
	match shape:
		ShapeBuilder.Type.CIRCLE:
			ShapeBuilder.generate_circle(projectile_size, polygon_2d)
		ShapeBuilder.Type.TRIANGLE:
			ShapeBuilder.generate_triangle(projectile_size, polygon_2d)
		ShapeBuilder.Type.SQUARE:
			ShapeBuilder.generate_square(projectile_size, polygon_2d)
	collision_shape_2d.polygon = polygon_2d.polygon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * projectile_speed * delta
	


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Asteroid:
		var asteroid = area
		asteroid.explode()
		queue_free()
