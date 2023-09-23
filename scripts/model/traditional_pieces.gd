class_name TraditionalPieces



class Pawn:
	extends ChessPiece

	var has_moved : bool = false
	var en_passantable_coords : Array[ChessBoard.Square] = []

	func _init(piece_color:ChessPiece.PieceColor):
		color = piece_color
		name = "Pawn"
		point_value = 1 

	func move(board: ChessBoard, current_square: ChessBoard.Square, target_square: ChessBoard.Square):
		super.move(board, current_square, target_square)
		if (current_square.coordinates - target_square.coordinates).length() > 1:
			var en_passantable_coord :Vector2 = target_square.coordinates - color.move_direction
			en_passantable_coords.append(board.get_square(en_passantable_coord))
		has_moved = true

	func get_valid_moves(board: ChessBoard, current_square: ChessBoard.Square) -> Array[ChessBoard.Square]:
		var new_square : ChessBoard.Square = board.get_square(current_square.coordinates + color.move_direction)
		if new_square == null or new_square.piece != null:
			return []
		var valid:Array[ChessBoard.Square] = [new_square]
		if !has_moved:
			new_square = board.get_square(current_square.coordinates + color.move_direction * 2)
			if new_square != null and new_square.piece == null:
				valid.append(new_square)

		return valid

	func get_valid_takes(board:ChessBoard, current_square:ChessBoard.Square):
		var take_squares : Array[ChessBoard.Square] = [
			board.get_square(current_square.coordinates + color.move_direction + color.get_perpendicular_direction()),
			board.get_square(current_square.coordinates + color.move_direction - color.get_perpendicular_direction())
		]
		var valid_takes : Array[ChessBoard.Square] = []
		for square in take_squares:
			if square != null and ((square.piece != null and square.piece.color != color) or len(get_en_passant_pieces(square, board)) > 0):
				valid_takes.append(square)


		return valid_takes

	func get_en_passant_pieces(square:ChessBoard.Square, board: ChessBoard) -> Array[ChessBoard.Square]:
		var valid_en_passant_pieces : Array[ChessBoard.Square] = []
		for row in board.squares:
			for ep_square in row.row:
				if ep_square.piece != null and ep_square.piece.color != color and ep_square.piece.get("en_passantable_squares") != null:
					var pawn : ChessPiece = ep_square.piece
					if pawn.en_passantable_squares.contains(square):
						valid_en_passant_pieces.append(ep_square)
		return valid_en_passant_pieces

	

	func on_turn_start(turn_color: ChessPiece.PieceColor):
		if turn_color == color:
			en_passantable_coords = []
			


static func get_traditional_board_setup():
	var board:ChessBoard = ChessBoard.new(Vector2(8,8))
	
	#Pawns
	for i in range(8):
		board.get_square(Vector2(i,1)).piece = Pawn.new(ChessPiece.Black.new())
		board.get_square(Vector2(i,6)).piece = Pawn.new(ChessPiece.White.new())

	return board
