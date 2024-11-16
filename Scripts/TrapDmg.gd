extends Area2D


func _on_body_entered(_body):
	print("TrapDmg(): Collided with player!")


func _on_area_entered(area):
	print("TrapDmg(): Area entered = " + str(area))
