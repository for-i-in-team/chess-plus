class_name ChessBoardView
extends Node2D

@export var chess_square_node : PackedScene
@export var board_size : Vector2 = Vector2(8,8)
@export var input : ChessInput
var board :ChessBoard
var bot : ChessAI

# Called when the node enters the scene tree for the first time.
func _ready():
	board = BomberMan.get_bomberman_board()
	input.init(self, ChessPiece.PieceColor.white, board.current_turn)
	for row in board.board:
		for square in row.row:
			var square_view:ChessSquareView = chess_square_node.instantiate()
			square_view.init(self, square)
			add_child(square_view)
			square_view.square_selected.connect(input.handle_selection) 

	board.events.game_over.connect_sig(func(color:ChessPiece.PieceColor):print("Color Won: " + color.name))
	board.events.stalemated.connect_sig(func(color:ChessPiece.PieceColor):print("Color Tied: " + color.name))

	#bot = ChessAI.new(ChessPiece.PieceColor.black, board)

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
			print(SteamSession.current_lobby.hosting)
			SteamSession.current_lobby._send_p2p_packet({"test": "space pressed"}, 0)

func _process(_delta):
	if SteamSession.current_lobby != null and SteamSession.current_lobby.board == null:
		SteamSession.current_lobby.attach_lobby_to_board(board)

	if SteamSession.current_lobby != null and SteamSession.current_lobby.board != null and not SteamSession.current_lobby.hosting:
		#bot = ChessAI.new(ChessPiece.PieceColor.black, board)
		input.color = ChessPiece.PieceColor.black
