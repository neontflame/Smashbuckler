extends Node
class_name FighterUtils

@export var fighter:Fighter

func is_jump_just_pressed():
	return Input.is_action_just_pressed("ctrl_up") \
	or Input.is_action_just_pressed("ctrl_X") \
	or Input.is_action_just_pressed("ctrl_Y")

func is_jump_just_released():
	return Input.is_action_just_released("ctrl_up") \
	or Input.is_action_just_released("ctrl_X") \
	or Input.is_action_just_released("ctrl_Y")

func is_shoulder_just_pressed():
	return Input.is_action_just_pressed("ctrl_R") \
	or Input.is_action_just_pressed("ctrl_L")
