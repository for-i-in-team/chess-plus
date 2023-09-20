from models.base_piece import ChessPiece
from utils.base import Coordinate, Sprite
import resources


class PieceView(Sprite):
    def __init__(self, piece: ChessPiece, pos: Coordinate, size: int, *groups) -> None:
        self.piece: ChessPiece = piece
        image = resources.get_piece(piece)
        super().__init__(image, pos, size, size, *groups)
