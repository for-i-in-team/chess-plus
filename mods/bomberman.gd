class_name BomberMan

extends GameEffect


func set_board(_board:ChessBoard):
	super.set_board(_board)
	_board.events.piece_taken.connect_sig(func(take): explode(take))

func explode(take:ChessPiece.Take):
	if take is BombTake:
		return
	var targets:Array[ChessBoard.Square] = []
	for direction in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
		var square:ChessBoard.Square = board.get_square(take.to_square.coordinates + direction)
		while square != null:
			if square.piece != null:
				targets.append(square)
				square.piece = null
			square = board.get_square(square.coordinates + direction)


	var new_take:BombTake = BombTake.new(take.to_square, take.to_square, targets)
	board.events.piece_taken.emit([new_take])


func copy(_board:ChessBoard):
	var new:BomberMan = BomberMan.new()
	new.set_board(_board)
	return new

class BombTake:
	extends ChessPiece.Take

static func get_bomberman_board():
	var _board:ChessBoard = ChessBoard.new(Vector2(8,8), [GameConstraint.FriendlyFireConstraint.new(), GameConstraint.NoCheckConstraint.new()])
	TraditionalPieces.lay_out_traditional_board(_board)
	_board.add_effect(BomberMan.new())
	_board.add_effect(GameEffect.EndOnCheckmate.new())
	_board.add_effect(GameEffect.EndOnStalemate.new())
	_board.add_effect(GameEffect.PiecesPromoteToQueens.new())

	return _board
