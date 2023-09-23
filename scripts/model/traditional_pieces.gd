class_name TraditionalPieces



class Pawn:
	extends ChessPiece

	var has_moved : bool = false
	var en_passantable_coords : Array[ChessBoard.Square] = []

	func _init(_color:ChessPiece.PieceColor):
		super._init("Pawn", _color, 1)

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

	func take(board: ChessBoard, current_square: ChessBoard.Square, target_square: ChessBoard.Square):
		if target_square in get_valid_takes(board, current_square):
			var taken_piece:ChessPiece = target_square.piece
			var en_passant_squares : Array[ChessBoard.Square] = get_en_passant_pieces(target_square, board)
			
			current_square.piece = null
			target_square.piece = self
			
			if len(en_passant_squares) > 0:
				for square in en_passant_squares:
					square.piece = null
					board.events.piece_taken.emit(current_square, target_square, self, square.piece)
			if taken_piece != null:
				board.events.piece_taken.emit(current_square, target_square, self, target_square.piece)
		else:
			assert( target_square in get_valid_takes(board, current_square), "Invalid move %s -> %s" % [current_square.to_string(), target_square.to_string()])

	func get_valid_takes(board:ChessBoard, current_square:ChessBoard.Square):
		var take_squares : Array[ChessBoard.Square] = [
			board.get_square(current_square.coordinates + color.move_direction + color.get_perpendicular_direction()),
			board.get_square(current_square.coordinates + color.move_direction - color.get_perpendicular_direction())
		]
		var valid_takes : Array[ChessBoard.Square] = []
		for square in take_squares:
			if square != null and ((square.piece != null and square.piece.color != color) or  len(get_en_passant_pieces(square, board)) > 0):
				valid_takes.append(square)


		return valid_takes

	func get_en_passant_pieces(square:ChessBoard.Square, board: ChessBoard) -> Array[ChessBoard.Square]:
		var valid_en_passant_pieces : Array[ChessBoard.Square] = []
		if square.piece != null and square.piece.color == color:
			return valid_en_passant_pieces
		for row in board.board:
			for ep_square in row.row:
				if ep_square.piece != null and ep_square.piece.color != color and ep_square.piece.get("en_passantable_coords") != null:
					var pawn : ChessPiece = ep_square.piece
					if square in pawn.en_passantable_coords:
						valid_en_passant_pieces.append(ep_square)
		return valid_en_passant_pieces

	

	func on_turn_start(turn_color: ChessPiece.PieceColor):
		if turn_color == color:
			en_passantable_coords = []
			
class Rook:
	extends ChessPiece

	func _init(_color:ChessPiece.PieceColor):
		super._init("Rook", _color, 1)

	func get_valid_moves(board: ChessBoard, current_square: ChessBoard.Square) -> Array[ChessBoard.Square]:
		return _orthogonal_where(board, current_square, func(square:ChessBoard.Square): return square.piece == null)

	func get_valid_takes(board:ChessBoard, current_square:ChessBoard.Square):
		var valid : Array[ChessBoard.Square] = []
		for direction in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
			var square = test_in_direction(board, current_square, direction, func(square:ChessBoard.Square): return square.piece != null)
			if square != null and square.piece.color != color:
				valid.append(square)
		return valid


static func get_traditional_board_setup():
	var board:ChessBoard = ChessBoard.new(Vector2(8,8))
	
	# Pawns
	for i in range(8):
		board.get_square(Vector2(i,6)).piece = Pawn.new(ChessPiece.PieceColor.black)
		board.get_square(Vector2(i,1)).piece = Pawn.new(ChessPiece.PieceColor.white)

	# Rooks
	board.get_square(Vector2(0,7)).piece = Rook.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(7,7)).piece = Rook.new(ChessPiece.PieceColor.black)
	board.get_square(Vector2(0,0)).piece = Rook.new(ChessPiece.PieceColor.white)
	board.get_square(Vector2(7,0)).piece = Rook.new(ChessPiece.PieceColor.white)

	return board
