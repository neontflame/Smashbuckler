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

var INPUT_BUFFER:Array = []
var INPUT_BUFFER_FRAMES:int = 20
#endregion

#region Cool Teknix
var inputtableControls:Array[StringName] = [
	"ctrl_left",
	"ctrl_right",
	"ctrl_down",
	"ctrl_up",
	"ctrl_A",
	"ctrl_B",
	"ctrl_Z",
	"ctrl_X",
	"ctrl_R",
	"ctrl_L"
]

func handleInputBuffer():
	var now = Engine.get_process_frames()
	INPUT_BUFFER = INPUT_BUFFER.filter(func(e): return now - e.frame < INPUT_BUFFER_FRAMES)
	
	for cont in inputtableControls:
		if Input.is_action_just_pressed(cont):
			INPUT_BUFFER.append({"action": cont, "frame": now, "releasedFrames": -1})
		if Input.is_action_just_released(cont):
			for inp in INPUT_BUFFER:
				if inp.action == cont and inp.releasedFrames == -1:
					inp.releasedFrames = now - inp.frame
					print(INPUT_BUFFER)

func resetInputBuffer():
	INPUT_BUFFER = []
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
# quick advice: for every attack that has a *, means it's an alternative keybind!
var groundAttackAwesomes: Dictionary = {
	"AttackJab":      ["ctrl_A"],
	"AttackTiltSide":  ["ctrl_right", "ctrl_A"],
	"AttackTiltSide*": ["ctrl_left", "ctrl_A"],
	"AttackTiltU":    ["ctrl_up", "ctrl_A"],
	"AttackTiltD":    ["ctrl_down", "ctrl_A"],
}

var aerialAttackAwesomes: Dictionary = {
	"AttackAirN": ["ctrl_A"],
	"AttackAirSide":  ["ctrl_right", "ctrl_A"],
	"AttackAirSide*": ["ctrl_left", "ctrl_A"],
	"AttackAirU": ["ctrl_up", "ctrl_A"],
	"AttackAirD": ["ctrl_down", "ctrl_A"],
}

var specialAwesomes: Dictionary = {
	"SpecialN": ["ctrl_B"],
	"SpecialF":  ["ctrl_B", "ctrl_right"],
	"SpecialF*": ["ctrl_B", "ctrl_left"],
	"SpecialU": ["ctrl_B", "ctrl_up"],
	"SpecialD": ["ctrl_B", "ctrl_down"],
}

func handleAttackBuffer():
	#todo: do this
	#whats needed:
		# differentiate between tilt and smash
		# jab combo
		# aerials
		# specials
	pass
#endregion

func _physics_process(delta: float) -> void:
	handleInputBuffer()
	handleAttackBuffer()
	
	if STUN_FRAMES > 0:
		STUN_FRAMES -= 1
		return
	
	velocity = motion
	move_and_slide()
