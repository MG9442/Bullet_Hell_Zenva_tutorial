extends Node
class_name StateMachine

@export var initial_state : State

var current_state : State
var states : Dictionary = {}

func _ready():
	# Fetch State names in Dictionary
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	#print(str(name) + " dictionary of State names = " + str(states))
	
	# Setup initial state
	if initial_state:
		initial_state._enter_state()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)

func on_child_transition(state, new_state_name : String):
	
	if state != current_state:
		print(str(name) + " Error, " + str(state) + " != " + str(current_state))
		return
	
	var new_state : State = states.get(new_state_name.to_lower())
	if !new_state:
		print(str(name) + " Error, " + str(new_state_name) + " not found!")
		return
	
	# Run exit state of previous state
	if current_state: 
		current_state._exit_state()
	
	# Run enter state of new state
	new_state._enter_state() 
	current_state = new_state
