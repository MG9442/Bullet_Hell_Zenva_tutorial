extends Area2D

# Enemy hurtbox Script

# Responsible for:
# Taking damage
# Knockback physics
# Bumping physics

# Dependencies:
# Enemy script

@export var enemy : CharacterBody2D
@export var bumpVector : RayCast2D
@export var bump_magnitude : int = 100

var Weapon_damage_func : String = "deal_damage"
var BodiesColliding : Array

signal TakeDamage # emit when taking damage

func _physics_process(delta):
	if BodiesColliding.size() > 0:
		#print("Bodies colliding = " + str(BodiesColliding))
		#if slowest_speed(): # Bump the slowest speed entity
		var direction  = direction_to_bump()
		set_raycast(direction)
		enemy.velocity = (direction * 10 * bump_magnitude * delta)
		enemy.move_and_slide()

func direction_to_bump() -> Vector2:
	var direction_vector : Vector2 = Vector2.ZERO # Direction vector based on colliding bodies
	for i in BodiesColliding.size():
		#print("BodiesColliding[" + str(i) + "] = " + str(BodiesColliding[i]))
		var direction = (BodiesColliding[i].global_position - self.global_position).normalized()
		direction = direction * -1
		direction_vector += direction
	return direction_vector

# Determine if this body is the slowest speed entity, to bump
func slowest_speed() -> bool:
	#print("self.velocity = " + str(enemy.velocity.length()))
	for i in BodiesColliding.size():
		#print("BodiesColliding[" + str(i) + "] = " + str(BodiesColliding[i]))
		if BodiesColliding[i].has_method("Variable_speed") and enemy.has_method("Variable_speed"):
			#print("BodiesColliding.VariedSpeed = " + str(BodiesColliding[i].VariedSpeed))
			if BodiesColliding[i].Variable_speed() < enemy.Variable_speed():
				return false # Colliding body is slower then self speed
	return true

func set_raycast(direction):
	if bumpVector:
		bumpVector.target_position = direction * 35

# Add a colliding body to list
func _on_body_entered(body):
	if body != enemy: # Do not add own colliding body to list
		#print("add_colliding_body(): body entered space = " + str(body))
		BodiesColliding.append(body)

# Remove colliding body from list
func _on_body_exited(body):
	#print("remove_colliding_body(): body exited space = " + str(body))
	BodiesColliding.erase(body)


func _on_area_entered(area):
	#print("SlimeHurtbox(): Enemy hit!")
	if area.owner.has_method(Weapon_damage_func):
		var damage = area.owner.deal_damage()
		TakeDamage.emit(damage)
		#print("SlimeHurtbox(): damage result = " + str(damage))
	else:
		print("SlimeHurtbox(): Error, area owner does not have func " + Weapon_damage_func)
