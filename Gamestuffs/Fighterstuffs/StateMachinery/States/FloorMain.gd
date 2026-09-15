extends FitStPtrn
class_name FitStFloorMain
# extend this state if your state uses generic floor movement!!!!!

func enterState():
	print("Floored")
	fighter.jumpsDone = 0
	fighter.jumping = false
	fighter.motion.y = 1

func update():
	fighter.handlePhys(get_physics_process_delta_time())
	if not fighter.is_on_floor():
		statesRoot.changeStateByName("AirMain")
