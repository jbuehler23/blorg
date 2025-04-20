class_name WarningOverlay extends CanvasLayer

signal warning_finished
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var warning_flash_timer: Timer = $WarningFlashTimer
@onready var warning_sfx: AudioStreamPlayer2D = $WarningSFX

func show_warning() -> void:
	visible = true
	animation_player.play("flash")
	warning_sfx.play()
	warning_flash_timer.start()


func _on_warning_flash_timer_timeout() -> void:
	animation_player.stop()
	visible = false
	warning_finished.emit()
	warning_sfx.stop()


func _on_warning_sfx_finished() -> void:
	warning_sfx.play()
