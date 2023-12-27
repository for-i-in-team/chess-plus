class_name VersusLobby

extends Node2D

@export var packed_board_view : PackedScene
@export var packed_player_list_item : PackedScene
var lobby : ChessLobby = null
var board_view : ChessBoardView = null

func _ready():
	if lobby == null:
		lobby = await ChessLobby.start_lobby()
		lobby.board = TraditionalPieces.get_traditional_board_setup()
	board_view = packed_board_view.instantiate()
	board_view.set_board(lobby.board)
	board_view.position = Vector2(board_view.position.x *1.5, board_view.position.y)
	add_child(board_view)

func set_lobby(_lobby:ChessLobby):
	self.lobby = _lobby

class Scene:
	extends SceneManager.Scene

	var lobby : ChessLobby = null

	func is_scene_ready(tree:SceneTree) -> bool:
		return tree.get_root().get_node_or_null("/root/VersusLobby") != null

	func on_scene_loaded(tree:SceneTree):
		if lobby != null:
			tree.get_root().get_node_or_null("/root/ChessBoard").set_lobby(lobby)

	func get_packed_scene() -> PackedScene:
		return preload("res://scenes/screens/versus_lobby.tscn")