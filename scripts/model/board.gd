

class_name ChessBoard

var size :Vector2
var board : Array[BoardRow] = []

func _init(board_size:Vector2):
    for i in range(board_size.y):
        size = board_size
        board.append(BoardRow.new(i,size.x as int))
		

class BoardRow:
    var row:Array[ChessSquare]
    func _init(row_num:int, row_length:int, ):
        for i in range(row_length):
            var color : ChessBoard.SquareColor = (ChessBoard.Black.new() as ChessBoard.SquareColor) if (i+row_num)%2 == 0 else ChessBoard.White.new()
            row.append(ChessSquare.new(color))

class ChessSquare:
    var color:ChessBoard.SquareColor
    var piece

    func _init( square_color:ChessBoard.SquareColor):
        color  = square_color


class SquareColor:
    var color: Color

class Black: 
    extends SquareColor 
    func _init():
        self.color = Color.BLACK

class White:
    extends SquareColor
    func _init():
        self.color = Color.WHITE
    