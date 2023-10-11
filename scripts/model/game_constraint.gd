class_name GameConstraint

var requires_next_state:bool
var name:String
var description:String

func _init(_name:String,_description:String, _requires_next_state:bool):
	requires_next_state = _requires_next_state
	name = _name
	description = _description

func validate_move(_board:ChessBoard, _move:ChessPiece.Move, _next_state:ChessBoard) -> bool:
	return true

func validate_take(_board:ChessBoard, _take:ChessPiece.Take,_next_state:ChessBoard) -> bool:
	return true


class FriendlyFireConstraint:
	extends GameConstraint

	func _init():
		super._init("No Friendly Fire","Prevents a piece from moving to the same square as a friendly piece as part of a take",false)

	func validate_take(_board:ChessBoard, _take:ChessPiece.Take,_next_state:ChessBoard) -> bool:
		if _take.to_square.piece == null:
			return true # AUDIT Should we filter out friendly en-passant here? Or maybe elsewhere
		return _take.from_square.piece.color != _take.to_square.piece.color

class NoCheckConstraint:
	extends GameConstraint

	func _init():
		super._init("No Check","Prevents a piece from moving into check",true)

	func validate_move(_board:ChessBoard, _move:ChessPiece.Move, next_state:ChessBoard) -> bool:
		return no_checks(next_state, _move.from_square.piece.color)

	func validate_take(_board:ChessBoard, take:ChessPiece.Take,_next_state:ChessBoard) -> bool:
		return no_checks(_next_state, take.from_square.piece.color)

	func no_checks(board:ChessBoard, color:ChessPiece.PieceColor) -> bool:
		for row in board.board:
			for square in row.row:
				if square.piece != null and square.piece.color == color:
					var check_mod = square.piece.get_modifier(TraditionalPieces.Checkable)
					if check_mod != null and check_mod.is_in_check(square.piece, board, square):
						return false
		return true

class NoTraversingCheckConstraint:
	extends GameConstraint

	func _init():
		super._init("No Traversing Check","Prevents a piece from moving through a square that would put itself in check",false)

	func validate_move(_board:ChessBoard, _move:ChessPiece.Move, _next_state:ChessBoard) -> bool:
		var check_mod = _move.piece.get_modifier(TraditionalPieces.Checkable)
		if check_mod != null:
			# Create a copy of the board without the piece on it, to ensure it doesn't block any potential checks
			var new_board = _board.copy()
			new_board.get_square(_move.from_square.coordinates).piece = null
			for square in _move.traversed_squares:
				new_board.get_square(square.coordinates).piece = _move.piece
				if check_mod.is_in_check(_move.piece, new_board, new_board.get_square(square.coordinates)):
					return false
				new_board.get_square(square.coordinates).piece = null
		return true
