extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health = 0 : set = _set_health

# Setter function that gets called everytime the health value gets changed
func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health <= 0:
		queue_free()
	
	# Taking damage
	if health < prev_health:
		timer.start()
	# Healing
	else:
		damage_bar.value = health

# initialize the health bar values
func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

# Used to catch 
func _on_timer_timeout():
	damage_bar.value = health
