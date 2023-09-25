class_name Events

signal piece_moved(move: ChessPiece.Move)

signal piece_taken(take : ChessPiece.Take)

signal color_lost(color:ChessPiece.PieceColor)

signal game_over(winner:ChessPiece.PieceColor)

signal turn_started(color:ChessPiece.PieceColor)