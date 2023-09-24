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
		# AUDIT Hook this up to onTurnStart
		_board.events.piece_moved.connect(func(_piece,_from,_to): handle_move(_piece.color))

	func handle_move(color:ChessPiece.PieceColor):
		var opponent:ChessPiece.PieceColor 
		if color == ChessPiece.PieceColor.white:
			opponent = ChessPiece.PieceColor.black
		else:
			opponent = ChessPiece.PieceColor.white
		if is_checkmate(board, opponent):
			board.events.color_lost.emit(opponent)

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
