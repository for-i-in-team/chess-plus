class_name MainMenu
extends Node2D

@export var game_scene : PackedScene

func start_game():
	ChessBoardView.Scene.new(TraditionalPieces.get_traditional_board_setup()).load_scene()

func play_puzzle():
	pass

func play_multiplayer():
	pass

func level_creator():
	pass

func change_settings():
	pass

func quit_game():
	get_tree().quit()

