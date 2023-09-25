class_name GameEffect

var board:ChessBoard

func set_board(_board:ChessBoard):
	board = _board

func copy(_board:ChessBoard):
	pass

class EndOnCheckmate:
	extends GameEffect

	func set_board(_board:ChessBoard):
		super.set_board(_board)
		_board.events.turn_started.connect(func(color): handle_move(color))

	func handle_move(color:ChessPiece.PieceColor):
		if is_checkmate(board, color):
			board.events.color_lost.emit(color)

	func is_checkmate(_board:ChessBoard, color):
		var no_pieces:bool = true
		var checkable_pieces:Array[ChessBoard.Square] = []
		for row in board.board:
			for square in row.row:
				if square.piece != null && square.piece.color == color:
					no_pieces = false 
					if square.piece.has_method("is_in_check"):
						checkable_pieces.append(square)
		if no_pieces:
			return true
		if len(board.get_all_moves(color)) == 0 and len(board.get_all_takes(color)) == 0:
			for square in checkable_pieces:
				if square.piece.is_in_check(board, square):
					return true
		
		return false

	func copy(_board:ChessBoard):
		var new:EndOnCheckmate = EndOnCheckmate.new()
		new.set_board(_board)
		return new
class PiecesPromoteToQueens:
	extends GameEffect

	func set_board(_board:ChessBoard):
		super.set_board(_board)
		_board.events.promote_piece.connect(func(square): promote_pawn(square))

	func promote_pawn(square:ChessBoard.Square):
		if square.piece != null:
			square.piece = TraditionalPieces.Queen.new(square.piece.color)


	
