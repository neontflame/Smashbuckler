extends CharacterBody2D
class_name Fighter

@export_group("Attributes")
@export var ACCELERATION_WALK:float = 400.0
@export var ACCELERATION_RUN:float = 600.0

@export var MAX_WALK_SPEED:float = 200.0
@export var MAX_RUN_SPEED:float = 400.0

@export var DECELERATION:float = 400.0
@export var DECELERATION_AIR:float = 20.0
@export var BRAKE_SPEED:float = 1800.0

@export var WEIGHT:float = 300.0
@export var JUMP_HEIGHT:float = 600.0

@export var MAX_JUMPS:int = 2
@export_group("Technical")
@export var STATE_MACHINE:FitStMch

#region Variaveis coolio
var STUN_FRAMES:int = 0 # se for maior do que 0 voce esta Stunnado
var LAUNCH_FRAMES:int = 0 # voce esta sendo lançado no ar

var DAMAGE:float = 0.0

var MAX_FALL_SPEED:float = WEIGHT * 3
var boundByMaxFallSpeed:bool = true

var SMALL_JUMP_THRESHOLD:float = -60
var jumpsDone:int = 0
var jumping:bool = false
var comingFromAir:bool = false

var motion:Vector2 = Vector2.ZERO
#endregion

#region Cool Physics
func handlePhys(delta: float):
	#region Move Shit
	var coolAxis:float = Input.get_axis("ui_left", "ui_right")
	if LAUNCH_FRAMES <= 0:
		#go from Left to Righte
		if Input.is_action_pressed("ui_left") \
		or Input.is_action_pressed("ui_right"):
			if sign(motion.x) == -sign(coolAxis):
				motion.x += BRAKE_SPEED * sign(coolAxis) * delta
			if abs(motion.x) < MAX_WALK_SPEED:
				motion.x += ACCELERATION_WALK * sign(coolAxis) * delta
		else:
			motion.x -= (DECELERATION if is_on_floor() else DECELERATION_AIR) \
						* sign(motion.x) * delta
		
		#region Jump Shit
		if not is_on_floor():
			if MAX_JUMPS > 1 and jumpsDone == 0:
				jumpsDone = 1
		
		if Input.is_action_just_pressed("ui_up"):
			if is_on_floor() or (jumpsDone < MAX_JUMPS):
				jumping = true
				jumpsDone += 1
				motion.y = -JUMP_HEIGHT
		
		if jumping:
			if Input.is_action_just_released("ui_up"):
				if motion.y < SMALL_JUMP_THRESHOLD:
					motion.y = SMALL_JUMP_THRESHOLD
		#endregion
	#endregion
	
	#region Air Shit
	if LAUNCH_FRAMES <= 0 and boundByMaxFallSpeed:
		if motion.y > MAX_FALL_SPEED:
			motion.y = MAX_FALL_SPEED
	
	if not is_on_floor():
		comingFromAir = true
		motion.y += WEIGHT * delta
	else:
		if comingFromAir:
			comingFromAir = false
			on_land()
	#endregion

func on_land():
	jumpsDone = 0
	jumping = false
	motion.y = 1
#endregion

func _physics_process(delta: float) -> void:
	if STUN_FRAMES > 0:
		STUN_FRAMES -= 1
		return
	
	handlePhys(delta)
	velocity = motion
	move_and_slide()
