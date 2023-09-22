

class_name ChessBoard

var size :Vector2
var board : Array[BoardRow] = []

func _init(board_size:Vector2):
    for i in range(board_size.y):
        size = board_size
        board.append(BoardRow.new(i,size.x as int))
		

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
        return "Square: (" + (coordinates.x as String) + "," + (coordinates.y as String) + ") " + piece.to_string()


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
    