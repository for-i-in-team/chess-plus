

class_name ChessBoard

var size :Vector2
var board : Array[BoardRow] = []

func _init(board_size:Vector2):
	for i in range(board_size.y):
		size = board_size
		board.append(BoardRow.new(i,size.x as int))

func get_square(coordinates:Vector2):
	if coordinates.x < 0 or coordinates.x >= size.x or coordinates.y < 0 or coordinates.y >= size.y:
		return null
	else:
		# AUDIT Do we need to swap the rows to columns so that we can access
		return board[coordinates.y as int].row[coordinates.x as int]
		

class BoardRow:
	var row:Array[Square]
	func _init(row_num:int, row_length:int, ):
		for i in range(row_length):
			var color : ChessBoard.SquareColor = (ChessBoard.Black.new() as ChessBoard.SquareColor) if (i+row_num)%2 == 0 else ChessBoard.White.new()
			row.append(Square.new(color, Vector2(i,row_num)))

class Square:
	var color:ChessBoard.SquareColor
	var coordinates : Vector2
	var piece : ChessPiece

	func _init( square_color:ChessBoard.SquareColor, coord : Vector2):
		color  = square_color
		coordinates = coord

	func _to_string():
		return "Square: (%f,%f) %s"%[coordinates.x, coordinates.y, piece]


class SquareColor:
	var color: Color

class Black: 
	extends SquareColor 
	func _init():
		self.color = Color(0.15, 0.22, 0.51, 1)

class White:
	extends SquareColor
	func _init():
		self.color = Color.WHITE
	
