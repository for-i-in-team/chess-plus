class_name Events

var piece_moved = Utils.AsyncSignal.new(["move: ChessPiece.Move"])

var piece_taken = Utils.AsyncSignal.new(["take : ChessPiece.Take"])

var color_lost = Utils.AsyncSignal.new(["color:ChessPiece.PieceColor"])

var game_over = Utils.AsyncSignal.new(["winner:ChessPiece.PieceColor"])

var turn_started = Utils.AsyncSignal.new(["color:ChessPiece.PieceColor"])

var promote_piece = Utils.AsyncSignal.new(["square:ChessBoard.Square"])

var stalemated = Utils.AsyncSignal.new(["color:ChessPiece.PieceColor"])
