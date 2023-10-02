class_name ChessAI

var color : ChessPiece.PieceColor
var board : ChessBoard

func _init(_color : ChessPiece.PieceColor, _board : ChessBoard):
	color = _color
	board = _board

	board.events.turn_started.connect_sig(func (_color : ChessPiece.PieceColor):
		if _color == color:
			play_turn()
	)


func play_turn():
	print(Time.get_unix_time_from_system (), ": ", "Play Turn Start")
	var takes = board.get_all_takes(color)
	if len(takes) > 0:
		var best_take = takes[randi() % len(takes)]
		for take in takes:
			if take.get_value() > best_take.get_value():
				best_take = take
		await(board.take(best_take.from_square, best_take.to_square))
	else:
		var moves = board.get_all_moves(color)
		if len(moves)>0:
			var move = moves[randi() % len(moves)]
			await(board.move(move.from_square, move.to_square))
	print(Time.get_unix_time_from_system (), ": ", "Play Turn End")
