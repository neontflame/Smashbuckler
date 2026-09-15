extends FitStPtrn
class_name FitStAirMain
# extend this state if your state uses generic air movement!!!!!
var CAN_AIRDODGE:bool = true

func enterState():
	print("Aired")

func update():
	fighter.handlePhys(get_physics_process_delta_time())
	
	if fighter.is_on_floor():
		statesRoot.changeStateByName("FloorMain")
