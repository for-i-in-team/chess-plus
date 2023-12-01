class Puzzle:
	extends ChessBoard.Puzzle

	func get_name() -> String:
		return "Traditional"

	func get_board() -> ChessBoard:
		return TraditionalPieces.get_traditional_board_setup()