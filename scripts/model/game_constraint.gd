class_name GameConstraint

var requires_next_state:bool
var name:String
var description:String

func _init(_name:String,_description:String, _requires_next_state:bool):
	requires_next_state = _requires_next_state
	name = _name
	description = _description

func validate_move(_board:ChessBoard, _origin:ChessBoard.Square, _destination:ChessBoard.Square, _next_state:ChessBoard) -> bool:
	return true

func validate_take(_board:ChessBoard, _take:ChessPiece.Take,_next_state:ChessBoard) -> bool:
	return true


class FriendlyFireConstraint:
	extends GameConstraint

	func _init():
		super._init("No Friendly Fire","Prevents a piece from moving to the same square as a friendly piece as part of a take",false)

	func validate_take(_board:ChessBoard, _take:ChessPiece.Take,_next_state:ChessBoard) -> bool:
		if _take.to_square.piece == null:
			return true
		return _take.from_square.piece.color != _take.to_square.piece.color

class NoCheckConstraint:
	extends GameConstraint

	func _init():
		super._init("No Check","Prevents a piece from moving into check",true)

	func validate_move(_board:ChessBoard, origin:ChessBoard.Square, _destination:ChessBoard.Square, next_state:ChessBoard) -> bool:
		return no_checks(next_state, origin.piece.color)

	func validate_take(_board:ChessBoard, take:ChessPiece.Take,_next_state:ChessBoard) -> bool:
		return no_checks(_next_state, take.from_square.piece.color)

	func no_checks(board:ChessBoard, color:ChessPiece.PieceColor) -> bool:
		for row in board.board:
			for square in row.row:
				if square.piece != null and square.piece.color == color and square.piece.has_method("is_in_check"):
					if square.piece.is_in_check(board, square):
						return false
		return true

