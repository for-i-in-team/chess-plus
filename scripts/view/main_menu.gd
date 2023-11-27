class_name MainMenu
extends Node2D

func play_puzzle():
	LevelSelectMenu.Scene.new().load_scene()

func play_multiplayer():
	pass

func level_creator():
	pass

func change_settings():
	pass

func quit_game():
	get_tree().quit()

