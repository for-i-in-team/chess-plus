class_name PuzzleDisplay

extends Node2D

func set_puzzle(p:LevelSelectMenu.Puzzle):
	$Button.text = p.get_name()

func get_on_press():
	return $Button.pressed
