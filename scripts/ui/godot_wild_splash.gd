extends Control

@export var game_scene := preload("res://scenes/screens/game.tscn")
@export var in_time := 0.5
@export var fade_in_time := 1.5
@export var pause_time := 2.5
@export var fade_out_time := 1.5
@export var out_time := 0.5
@onready var wildcards: TextureRect = $CenterContainer/Wildcards

func fade() -> void:
	wildcards.modulate.a = 0.0
	var tween = self.create_tween()
	tween.tween_interval(in_time)
	tween.tween_property(wildcards, "modulate:a", 1.0, fade_in_time)
	tween.tween_interval(pause_time)
	tween.tween_property(wildcards, "modulate:a", 0.0, fade_out_time)
	tween.tween_interval(out_time)
	await tween.finished
	get_tree().change_scene_to_packed(game_scene)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade()
