extends Control

@onready var debug_score: Label = $MarginContainer/DebugScore:
	set(value):
		debug_score.text = "SCORE: " + str(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
