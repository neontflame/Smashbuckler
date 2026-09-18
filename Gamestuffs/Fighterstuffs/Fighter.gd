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
@export var UTILS:FighterUtils
@export var SPRITE:AnimatedSprite2D

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

var AIRDODGED:bool = false

var COMBO_LENIENCY:float = 0.1
#endregion

#region Cool Teknix
var actionList = [
		"ctrl_left",
		"ctrl_down",
		"ctrl_up",
		"ctrl_right",
		"ctrl_A",
		"ctrl_B",
		"ctrl_X",
		"ctrl_Y",
		"ctrl_Z",
		"ctrl_R",
		"ctrl_L"
	]
var lastPressStr:Dictionary = {}

func _input(event: InputEvent) -> void:
	for action in actionList:
		if event.is_action_pressed(action):
			lastPressStr[action] = [Time.get_ticks_msec() / 1000.0, event.get_action_strength(action)]

func check_multiple_input(actions:Array[String]):
	for action in actions:
		if not lastPressStr.has(action):
			return false
	
	var firstInputTime:float = -1
	var lastInputTime:float = 0
	
	for action in actions:
		if (firstInputTime == -1) \
		or (firstInputTime > lastPressStr[action][0]):
			firstInputTime = lastPressStr[action][0]
		
		if (lastInputTime < lastPressStr[action][0]):
			lastInputTime = lastPressStr[action][0]
	
	var isTrued:bool = abs(firstInputTime - lastInputTime) <= COMBO_LENIENCY
	
	if isTrued:
		for action in actions:
			lastPressStr.erase(action)
	
	return isTrued

func check_Press_Justpress(pressed:Array[String], justPressed:Array[String]):
	for action in pressed:
		if not Input.is_action_pressed(action):
			return false
	
	for action in justPressed:
		if not Input.is_action_just_pressed(action):
			return false
	
	return true
#endregion

#region Cool Physics
func handlePhys(delta:float, canControl:bool = true):
	#region Move Shit
	var coolAxis:float = Input.get_axis("ctrl_left", "ctrl_right")
	if canControl:
		#go from Left to Righte
		if Input.is_action_pressed("ctrl_left") \
		or Input.is_action_pressed("ctrl_right"):
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
		
		if UTILS.is_jump_just_pressed():
			if is_on_floor() or (jumpsDone < MAX_JUMPS):
				jumping = true
				jumpsDone += 1
				motion.y = -JUMP_HEIGHT
		
		if jumping:
			if UTILS.is_jump_just_released():
				if motion.y < SMALL_JUMP_THRESHOLD:
					motion.y = SMALL_JUMP_THRESHOLD
		#endregion
	#endregion
	#region Air Shit
	if canControl and boundByMaxFallSpeed:
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
	pass
#endregion

#region Cool Stateness
func handleAttackInput():
	# todo: change All these prints for Actual states
	# Or functions that change the state
	# iunno
	
	# specialshit
	if check_Press_Justpress(["ctrl_left"], ["ctrl_B"]) \
	or check_Press_Justpress(["ctrl_right"], ["ctrl_B"]):
		print("side special")
	elif check_Press_Justpress(["ctrl_up"], ["ctrl_B"]):
		print("up special")
	elif check_Press_Justpress(["ctrl_down"], ["ctrl_B"]):
		print("down special")
	elif Input.is_action_just_pressed("ctrl_B"):
		print("neutral special")
	
	# groundshit
	if is_on_floor():
		# smash/tilt
		# forward smash (left)
		if check_multiple_input(["ctrl_left", "ctrl_A"]):
			if Input.get_action_strength("ctrl_left") > 0.75:
				print("left smash")
			else:
				print("left tilt")
		# forward smash (right)
		elif check_multiple_input(["ctrl_right", "ctrl_A"]):
			if Input.get_action_strength("ctrl_right") > 0.75:
				print("right smash")
			else:
				print("right tilt")
		# up smash
		elif check_multiple_input(["ctrl_up", "ctrl_A"]):
			if Input.get_action_strength("ctrl_up") > 0.75:
				print("up smash")
			else:
				print("up tilt")
		# down smash
		elif check_multiple_input(["ctrl_down", "ctrl_A"]):
			if Input.get_action_strength("ctrl_down") > 0.75:
				print("down smash")
			else:
				print("down tilt")
		elif Input.is_action_just_pressed("ctrl_A"):
			#todo: dash attack
			print("start jab")
	else:
		# forward/back air
		if check_Press_Justpress(["ctrl_left"], ["ctrl_A"]) \
		or check_Press_Justpress(["ctrl_right"], ["ctrl_A"]):
			var axis:float = Input.get_axis("ctrl_left", "ctrl_right")
			var facedDir:float = -1.0 if SPRITE.flip_h else 1.0
			
			if sign(axis) != sign(facedDir):
				print("back air")
			else:
				print("forward air")
		# up air
		elif check_Press_Justpress(["ctrl_up"], ["ctrl_A"]):
			print("up air")
		# down air
		elif check_Press_Justpress(["ctrl_down"], ["ctrl_A"]):
			print("down air")
		# neutral air
		elif Input.is_action_just_pressed("ctrl_A"):
			print("neut air")
#endregion

func _physics_process(delta: float) -> void:
	handleAttackInput() # maybe this should go on the individual states instead of here?
	
	if STUN_FRAMES > 0:
		STUN_FRAMES -= 1
		return
	
	velocity = motion
	move_and_slide()
