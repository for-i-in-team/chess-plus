class_name ChessSquareView

extends Area2D

@export var piece_scene : PackedScene
var color:ChessBoard.SquareColor
var square : ChessBoard.Square
var mouse_hovered:bool = false

signal square_selected(square:ChessSquareView)

func _ready():
	mouse_entered.connect(func():mouse_hovered = true)
	mouse_exited.connect(func():mouse_hovered = false)

func init(board: ChessBoardView, chess_square:ChessBoard.Square):
	square = chess_square
	$sprite.modulate = square.color.color
	position =  Vector2(square.coordinates.x, board.board.size.y-1 -square.coordinates.y) * $sprite.texture.get_width()*$sprite.scale
	set_piece(square.piece)
	board.board.events.piece_moved.connect(func(move:ChessPiece.Move):
		if move.from_square == square:
			set_piece(null)
		if move.to_square == square:
			set_piece(move.to_square.piece)
		for _move in move.incidental:
			if _move.from_square == square:
				set_piece(null)
			if _move.to_square == square:
				set_piece(_move.to_square.piece)
	)

	board.board.events.piece_taken.connect(func(take:ChessPiece.Take):
		if take.from_square == square or square in take.targets:
			set_piece(null)
		if take.to_square == square:
			set_piece(take.to_square.piece)
	)
	
func set_piece(piece:ChessPiece):
	if piece != null:
		var piece_view = piece_scene.instantiate()
		piece_view.init(piece)
		add_child(piece_view)
	else:
		for child in get_children():
			if child is ChessPieceView:
				remove_child(child)

func get_sprite_scale():
	return $sprite.scale

func _input(event):
	if mouse_hovered and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			square_selected.emit(self)
