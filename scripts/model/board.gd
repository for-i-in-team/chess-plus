

class_name ChessBoard




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
    