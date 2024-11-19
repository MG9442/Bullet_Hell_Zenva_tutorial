extends Node2D

@onready var EnemiesContainer = $"../Enemies"

var spawner_array : Array
var Slime_enemy: PackedScene = preload("res://Scenes/green_slime.tscn")
var spawn_location : Vector2
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children(): #Add childern into array
		spawner_array.append(child)
	#print("SpawnerManager, spawner array = " + str(spawner_array))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("SpawnEnemy"):
		Spawn_enemies(1)

func choose_rand_spawner():
	var rand_number = rng.randi_range(0, spawner_array.size())
	spawn_location = spawner_array[rand_number].global_position #Assign random spawning point
	print("Spawner[" + str(rand_number) + "], global_position = " + str(spawn_location))

func Spawn_enemies(num_enemies : int):
	for enemy in num_enemies:
		var spawned_enemy: Node = Slime_enemy.instantiate()
		EnemiesContainer.add_child(spawned_enemy)
	print("Spawn_enemies")
