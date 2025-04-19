class_name Asteroid extends Area2D

signal exploded(pos, size, points)
signal sucked()

var movement_vector := Vector2(0, -1)
var speed := 50.0
@export var asteroid_size := AsteroidSize.LARGE
@export var shape := ShapeBuilder.Type.TRIANGLE

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@export var points: int = 0

enum AsteroidSize {
	BOSS,
	LARGE,
	MEDIUM,
	SMALL
}

var is_being_sucked := false
var suck_target := Vector2.ZERO
var suck_speed := 200.0
var rotation_speed := 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation = randf_range(0, 2 * PI)
	#0 -> square, 1-> triangle, 2-> circle
	var shape_size = null
	match asteroid_size:
		AsteroidSize.BOSS:
			speed = randf_range(250.0, 300.0)
			shape_size = 150
			points = 250
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
	shape = ShapeBuilder.generate_random_shape(shape_size, polygon_2d)
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
	
	if is_being_sucked:
		var dir = (suck_target - global_position).normalized()
		global_position += dir * suck_speed * delta
		rotation += rotation_speed * delta
		scale = scale.move_toward(Vector2.ZERO, delta * 2.0)
		
		if global_position.distance_to(suck_target) < 10.0:
			sucked.emit()
			queue_free()

func explode() -> void:
	emit_signal("exploded", global_position, asteroid_size, points)
	queue_free()
	
	


func _on_body_entered(body: Node2D) -> void:
	if body is Ship:
		if body.shape == shape:
			##TODO: use a cooldown instead, seems to hard to restrict shooting entirely
			if body.charges < body.max_charges:
				print(str("increasing charges"))
				body.can_fire = true
				match asteroid_size:
					AsteroidSize.LARGE:
						body.charges += 5
					AsteroidSize.MEDIUM:
						body.charges += 3
					AsteroidSize.SMALL:
						body.charges += 1
				body.charge_changed.emit(body.charges, body.max_charges)
			queue_free()
		else:
			match asteroid_size:
					AsteroidSize.BOSS:
						body.damage(100)
					AsteroidSize.LARGE:
						body.damage(50)
					AsteroidSize.MEDIUM:
						body.damage(30)
					AsteroidSize.SMALL:
						body.damage(10)
						
func start_sucking(target: Vector2) -> void:
	is_being_sucked = true
	suck_target = target
	
