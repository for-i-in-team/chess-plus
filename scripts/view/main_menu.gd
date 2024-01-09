class_name MainMenu
extends Node2D

func play_puzzle():
	LevelSelectMenu.Scene.new().load_scene()

func play_campaign():
	pass

func play_multiplayer():
	VersusLobby.Scene.new(await(ChessLobby.start_lobby())).load_scene()

func level_creator():
	pass

func change_settings():
	pass

func quit_game():
	get_tree().quit()

class Scene:
	extends SceneManager.Scene

	func get_packed_scene() -> PackedScene:
		return preload("res://scenes/screens/MainMenu.tscn")
