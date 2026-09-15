extends Node
class_name FitStMch

@export var fighter:Fighter

var previousState:FitStPtrn = null
var currentState:FitStPtrn = null

func _ready() -> void:
	for nodely in get_children():
		nodely.statesRoot = self
		nodely.fighter = fighter
		nodely.stateName = nodely.name
		nodely.setup()
	
	currentState = $AirMain
	previousState = $Default

func changeState(state:FitStPtrn):
	previousState = currentState
	currentState = state
	previousState.exitState()
	currentState.enterState()

func changeStateByName(state:String):
	for nodely in get_children():
		if nodely.stateName == state:
			changeState(nodely)
			return
	print("Esse estado (", state, ") nao existe bro")

func _physics_process(delta: float) -> void:
	if fighter.STUN_FRAMES > 0: return
	
	if currentState:
		currentState.update()
