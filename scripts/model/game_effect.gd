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
		_board.events.turn_started.connect_sig(func(color): handle_move(color))

	func handle_move(color:ChessPiece.PieceColor):
		if is_checkmate(board, color):
			board.events.color_lost.emit([color])

	func is_checkmate(_board:ChessBoard, color):
		var no_pieces:bool = true
		var checkable_pieces:Array[ChessBoard.Square] = []
		for row in board.board:
			for square in row.row:
				if square.piece != null && square.piece.color == color:
					no_pieces = false 
					if square.piece.get_modifier(TraditionalPieces.Checkable) != null:
						checkable_pieces.append(square)
		if no_pieces:
			return true
		if len(board.get_all_moves(color)) == 0 and len(board.get_all_takes(color)) == 0:
			for square in checkable_pieces:
				if square.piece.get_modifier(TraditionalPieces.Checkable).is_in_check(square.piece,board, square):
					return true
		
		return false

	func copy(_board:ChessBoard):
		var new:EndOnCheckmate = EndOnCheckmate.new()
		new.set_board(_board)
		return new

class EndOnStalemate:
	extends GameEffect

	func set_board(_board:ChessBoard):
		super.set_board(_board)
		_board.events.turn_started.connect_sig(func(color): handle_move(color))

	func handle_move(color:ChessPiece.PieceColor):
		if is_stalemate(board, color):
			board.events.stalemated.emit([color])

	func is_stalemate(_board:ChessBoard, color):
		if len(board.get_all_moves(color)) == 0 and len(board.get_all_takes(color)) == 0:
			return true
		return false

	func copy(_board:ChessBoard):
		var new:EndOnStalemate = EndOnStalemate.new()
		new.set_board(_board)
		return new

class PiecesPromoteToQueens:
	extends GameEffect

	func set_board(_board:ChessBoard):
		super.set_board(_board)
		board.events.piece_moved.connect_sig(func(move): await(promote_pawn(move)))

	func promote_pawn(move:ChessPiece.Move):
		if move.piece is TraditionalPieces.Pawn:
			var next_square:Vector2 = move.to_square.coordinates + move.piece.color.move_direction
			if next_square.y < 0 or next_square.y >= board.size.y or next_square.x < 0 or next_square.x >= board.size.x:
				# Check whether the piece is null in case it was taken as part of the move
				if move.to_square.piece != null:
					var old_piece:ChessPiece = move.to_square.piece
					move.to_square.piece = TraditionalPieces.Queen.new(move.to_square.piece.color)
					move.piece = move.to_square.piece
					await(board.events.piece_change.emit([old_piece, move.to_square.piece]))

			
