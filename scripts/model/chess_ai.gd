class_name ChessAI

var color : ChessPiece.PieceColor
var board : ChessBoard
var search_depth:int = 1
var analysis_thread : Thread

func _init(_color : ChessPiece.PieceColor, _board : ChessBoard):
	color = _color
	board = _board
	analysis_thread = Thread.new()


	board.events.turn_started.connect_sig(func (_color : ChessPiece.PieceColor):
		if _color == color:
			if analysis_thread.is_started():
				analysis_thread.wait_to_finish()
			analysis_thread.start(play_turn)
	)

func play_turn():
	var start_time = Time.get_ticks_usec()
	var option = await(get_best_option(board, color, 0))
	option.option.apply_to_board.call_deferred(board)
	print("Turn took %s seconds" % str((Time.get_ticks_usec() - start_time) / 1000000.0))

func get_best_option(_board:ChessBoard, _color:ChessPiece.PieceColor, depth:int):
	var takes : Array[ChessPiece.Take] = await(_board.get_all_takes(_color))
	var moves : Array[ChessPiece.Move] = await(_board.get_all_moves(_color))
	moves.shuffle()
	var options : Array[ChessPiece.TurnOption] = []
	for take in takes:
		options.append(take)
	for i in range(min(5, len(moves))):
		options.append(moves[i])

	assert(len(options) > 0, "No moves available for this color on this board " + color.name)
	var indent : String = ""
	for i in range(depth):
		indent += "  "

	# Start with random option
	var best_option : ChessPiece.TurnOption = options[0]
	var initial_new_board = await(best_option.copy_on_board(_board))
	print("%sTrying move %s from %s to %s for %s" % [indent, best_option.piece.name, str(best_option.from_square.coordinates), str(best_option.to_square.coordinates), _color.name])
	var best_value = await(get_board_value_recursive(initial_new_board, _color, depth))
	print("%sValue of move %s from %s to %s is %s for %s" % [indent, best_option.piece.name, str(best_option.from_square.coordinates), str(best_option.to_square.coordinates), str(best_value), _color.name])

	# Test all options
	for option in options.slice(1):
		print("%sTrying move %s from %s to %s for %s" % [indent, option.piece.name, str(option.from_square.coordinates), str(option.to_square.coordinates), _color.name])
		var new_board = await(option.copy_on_board(_board))
		var value = await(get_board_value_recursive(new_board, _color, depth))
		print("%sValue of move %s from %s to %s is %s for %s" % [indent, option.piece.name, str(option.from_square.coordinates), str(option.to_square.coordinates), str(value), _color.name])
		if value > best_value:
			best_option = option
			best_value = value
	
	print("%sBest Option is %s to %s with value %s" % [indent, best_option.piece.name, best_option.to_square.coordinates, str(best_value)])
	return OptionValue.new(best_option, best_value)

func get_board_value_recursive(_board : ChessBoard, _color : ChessPiece.PieceColor, depth:int) -> int:
	if depth >= search_depth:
		return await(get_board_value(_board, _color))
	var indent : String = ""
	for i in range(depth):
		indent += "  "

	# Simulate opponents moves
	while _board.current_turn != _color:
		depth += 1
		indent += "  "
		if not _color in _board.colors:
			print("%sReturning board value of -99999 for %s" % [indent, _board.current_turn.name])
			return -99999
		var best_option : OptionValue = await(get_best_option(_board, _board.current_turn, depth))

		best_option.option.apply_to_board(_board)
	
	depth += 1
	indent += "  "

	var best_option : OptionValue = await(get_best_option(_board, _color, depth))
	print("%sReturning board value of %s for %s" % [indent, str(best_option.value), _color.name])
	return best_option.value

func get_board_value(_board : ChessBoard, _color : ChessPiece.PieceColor):
	var value = 0
	if len(_board.colors) == 0:
		return 99998 # Take anything other than a loss over a draw
	elif len(_board.colors) <= 1 and _board.colors[0] == _color:
		return 99999
	elif not _color in _board.colors:
		return -99999
	for row in _board.board: # TODO Factor available options into board value
		for square in row.row:
			if square.piece != null:
				if square.piece.color == _color:
					value += square.piece.point_value
				else:
					value -= square.piece.point_value
	value = value*10
	#value += len(await(_board.get_all_options(_color)))
	return value

class OptionValue:
	var option : ChessPiece.TurnOption
	var value : int

	func _init(_option : ChessPiece.TurnOption, _value : int):
		option = _option
		value = _value
