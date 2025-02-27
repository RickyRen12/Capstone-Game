extends ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_value_no_signal(0) # Start at 0 fill

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func bar_fill_up(seconds: int) -> void:
	set_value_no_signal(100)
	var duration = float(seconds)
	var time_elapsed = 0.0
	while time_elapsed < duration:
		await get_tree().create_timer(0.1).timeout # Small delay for smooth filling
		time_elapsed += 0.1
		value = max_value * (1 - (time_elapsed / duration)) # Gradually fill up
	set_value_no_signal(0)
