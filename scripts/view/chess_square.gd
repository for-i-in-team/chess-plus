class_name ChessSquareView

extends Area2D

@export var piece_scene : PackedScene
var color:ChessBoard.SquareColor
var square : ChessBoard.Square
var mouse_hovered:bool = false
var board:ChessBoardView
var piece_view:ChessPieceView

signal square_selected(square:ChessSquareView)

func _ready():
	mouse_entered.connect(func():mouse_hovered = true)
	mouse_exited.connect(func():mouse_hovered = false)

func init(_board: ChessBoardView, chess_square:ChessBoard.Square):
	board = _board
	square = chess_square
	$sprite.modulate = square.color.color
	position =  Vector2(square.coordinates.x - board.board.size.x/2, board.board.size.y -0.5 - board.board.size.y/2 -square.coordinates.y) * $sprite.texture.get_width()*$sprite.scale
	if square.piece != null:
		piece_view = piece_scene.instantiate()
		piece_view.init(board, square.piece)
		add_child(piece_view)

func get_sprite_scale():
	return $sprite.scale

func _input(event):
	if mouse_hovered and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			square_selected.emit(self)
