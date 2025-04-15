extends Camera2D

@export var shake_amount : float = 0
@export var default_offset : Vector2 = offset


@onready var timer: Timer = $Timer

var shake_active := false

func _ready():
	Global.camera = self
	default_offset = offset
	randomize()

func _process(_delta: float):
	if shake_active:
		offset = default_offset + Vector2(
			randf_range(-1, 1) * shake_amount,
			randf_range(-1, 1) * shake_amount
		)
	else:
		offset = default_offset


func shake(time: float, amount: float):
	shake_amount = amount
	shake_active = true
	timer.wait_time = time
	timer.start()



func _on_timer_timeout() -> void:
	shake_active = false
	offset = default_offset
