extends Control

@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar

func _on_game_score_updated(score: Variant, boss_spawn_threshold: Variant) -> void:
	progress_bar.value = score * 100 / boss_spawn_threshold
