class_name TheologicalDivide


static func get_board():
	var board:ChessBoard = ChessBoard.new(Vector2(12,8), [GameConstraint.FriendlyFireConstraint.new(), GameConstraint.NoCheckConstraint.new()])
	board.add_effect(GameEffect.EndOnCheckmate.new())
	board.add_effect(GameEffect.EndOnStalemate.new())
	board.add_effect(GameEffect.PiecesPromoteToQueens.new())
	board.add_effect(GameEffect.LoseOnCheckableTaken.new())
	
	for i in range(4,8):
		for j in range(8):
			if i < 6:
				if (j < 4 and i % 2 != j % 2) or (j >= 4 and i % 2 == j % 2):
					board.board[j].row[i] = ChessBoard.NonTraversibleSquare.new(ChessBoard.NullColor.new(), Vector2(i,j))
			else:
				if (j < 4 and i % 2 == j % 2) or (j >= 4 and i % 2 != j % 2):
					board.board[j].row[i] = ChessBoard.NonTraversibleSquare.new(ChessBoard.NullColor.new(), Vector2(i,j))


	# Pawns
	for i in range(8):
		if i < 4:
			board.get_square(Vector2(i,6)).piece = TraditionalPieces.Pawn.new(ChessPiece.PieceColor.black)
			board.get_square(Vector2(i,1)).piece = TraditionalPieces.Pawn.new(ChessPiece.PieceColor.white)
		else:
			board.get_square(Vector2(i+4,6)).piece = TraditionalPieces.Pawn.new(ChessPiece.PieceColor.black)
			board.get_square(Vector2(i+4,1)).piece = TraditionalPieces.Pawn.new(ChessPiece.PieceColor.white)

	# Rooks
	board.get_square(Vector2(0,7)).piece = TraditionalPieces.Rook.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(11,7)).piece = TraditionalPieces.Rook.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(0,0)).piece = TraditionalPieces.Rook.new(ChessPiece.PieceColor.white)
	board.get_square(Vector2(11,0)).piece = TraditionalPieces.Rook.new(ChessPiece.PieceColor.white)

	# Knights
	board.get_square(Vector2(1,7)).piece = TraditionalPieces.Knight.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(10,7)).piece = TraditionalPieces.Knight.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(1,0)).piece = TraditionalPieces.Knight.new(ChessPiece.PieceColor.white)
	board.get_square(Vector2(10,0)).piece = TraditionalPieces.Knight.new(ChessPiece.PieceColor.white)

	# Bishops
	board.get_square(Vector2(2,7)).piece = TraditionalPieces.Bishop.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(9,7)).piece = TraditionalPieces.Bishop.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(2,0)).piece = TraditionalPieces.Bishop.new(ChessPiece.PieceColor.white)
	board.get_square(Vector2(9,0)).piece = TraditionalPieces.Bishop.new(ChessPiece.PieceColor.white)

	# Queens
	board.get_square(Vector2(3,7)).piece = TraditionalPieces.Queen.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(3,0)).piece = TraditionalPieces.Queen.new(ChessPiece.PieceColor.white)

	# Kings
	board.get_square(Vector2(8,7)).piece = TraditionalPieces.King.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(8,0)).piece = TraditionalPieces.King.new(ChessPiece.PieceColor.white)
	
	board.colors = [ChessPiece.PieceColor.white, ChessPiece.PieceColor.black]

	
	return board


class Puzzle:
	extends ChessBoard.Puzzle

	func get_name() -> String:
		return "Theological Divide"

	func get_board() -> ChessBoard:
		return TheologicalDivide.get_board()
