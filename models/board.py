from __future__ import annotations
from enum import Enum, auto
from typing import TYPE_CHECKING

from utils.base import Coordinate

if TYPE_CHECKING:
    from models.base_piece import ChessPiece


class ChessBoard:
    def __init__(self, squares: list[list[ChessSquare]] | int) -> None:
        if isinstance(squares, int):
            self.size: Coordinate = Coordinate(squares, squares)
            self.squares: list[list[ChessSquare]] = [
                [
                    ChessSquare(
                        SquareColor.BLACK if (i + j) % 2 == 0 else SquareColor.WHITE,
                        Coordinate(i, j),
                    )
                    for j in range(squares)
                ]
                for i in range(squares)
            ]
        else:
            self.size = Coordinate(len(squares), max(len(row) for row in squares))
            self.squares: list[list[ChessSquare]] = squares


class ChessSquare:
    def __init__(self, color: SquareColor, coords: Coordinate) -> None:
        self.color: SquareColor = color
        self.coords: Coordinate = coords


class SquareColor(Enum):
    BLACK = (0, 0, 0)
    WHITE = (255, 255, 255)
