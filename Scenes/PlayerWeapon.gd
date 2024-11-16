extends Node2D

# Player Weapon Script

# Responsible for :
# base damage, calculating overall dmg based on player stats
# Notifying hurtbox of damage

@export var base_dmg : int = 10
@export var strength_modifier : float = 1.5

var weapon_dmg : float = 0
var stats_func : String = "character_stats"

func update_weapon_dmg():
	if owner != null:
		print("wood_hammer owner = " + str(owner))
		if owner.has_method(stats_func):
			var strength = owner.character_stats()
			weapon_dmg = base_dmg + (strength * strength_modifier)
			#print("PlayerWeapon(): new weapon damage = " + str(weapon_dmg))
		else:
			print("PlayerWeapon(): Error Owner does not have method " + stats_func)
	else:
		print("PlayerWeapon(): Error owner = null")
	return weapon_dmg

func deal_damage() -> float: #return damage for hurtbox
	if weapon_dmg == 0:
		weapon_dmg = update_weapon_dmg()
	return weapon_dmg
