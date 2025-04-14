extends Area2D

@export var projectile_speed := 500.0
var movement_vector := Vector2(0, -1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * projectile_speed * delta
	


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
