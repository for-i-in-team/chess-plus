class_name ChessBoardView
extends Node2D

@export var chess_square_node : PackedScene
@export var board_size : Vector2 = Vector2(8,8)
@export var input : ChessInput
var lobby : ChessLobby
var board :ChessBoard
var bot : ChessAI

# Called when the node enters the scene tree for the first time.
func _ready():
	board = BomberMan.get_bomberman_board()

	set_board(board)

	#bot = ChessAI.new(ChessPiece.PieceColor.black, board)

	SteamSession.lobby_joined.connect(func(): lobby=await(ChessLobby.new(self)))

func set_board(_board : ChessBoard):
	board = _board
	for i in get_children():
		if i is ChessSquareView:
			i.queue_free()

	input.init(self, ChessPiece.PieceColor.white, board.current_turn)
	for row in board.board:
		for square in row.row:
			var square_view:ChessSquareView = chess_square_node.instantiate()
			square_view.init(self, square)
			add_child(square_view)
			square_view.square_selected.connect(input.handle_selection) 

	board.events.game_over.connect_sig(func(color:ChessPiece.PieceColor):print("Color Won: " + color.name))
	board.events.stalemated.connect_sig(func(color:ChessPiece.PieceColor):print("Color Tied: " + color.name))


func get_square_view(square:ChessBoard.Square) -> ChessSquareView:
	for child in get_children():
		if child is ChessSquareView:
			var square_view:ChessSquareView = child as ChessSquareView
			if square_view.square.coordinates == square.coordinates:
				return square_view
	return null

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			if lobby == null:
				lobby = await(ChessLobby.start_lobby(self))
			if len(lobby.player_list) > 0:
				lobby.start_game(BomberMan.get_bomberman_board())
