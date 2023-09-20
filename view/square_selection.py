from __future__ import annotations
from typing import TYPE_CHECKING

from pygame import Surface

from utils.base import Coordinate, Sprite, ParentObject

if TYPE_CHECKING:
    from view.board import ChessBoardView, ChessSquareView
    from models.board import ChessSquare


class SquareSelection(ParentObject):
    def __init__(self, board: ChessBoardView, square: ChessSquareView, *groups) -> None:
        self.board: ChessBoardView = board
        self.square: ChessSquareView = square
        super().__init__(*groups)
        self.set_highlights()

    def set_highlights(self):
        self.children.append(
            SquareHighlight((0, 255, 0), self.square.pos, self.square.size)
        )
        piece = self.square.square.piece
        if piece is not None:
            for square in piece.get_valid_moves(self.square.square):
                self.children.append(
                    SquareHighlight(
                        (0, 0, 255),
                        self.get_square_pos(square),
                        self.square.size,
                    )
                )
            for square in piece.get_valid_takes(self.square.square):
                self.children.append(
                    SquareHighlight(
                        (255, 0, 0),
                        self.get_square_pos(square),
                        self.square.size,
                    )
                )

    def get_square_pos(self, square: ChessSquare):
        return (
            square.coords * self.square.size
            + self.board.top_left
            + int(self.square.size / 2)
        )


class SquareHighlight(Sprite):
    def __init__(
        self, color: tuple[int, int, int], pos: Coordinate, size: int, *groups
    ) -> None:
        image = Surface((size, size))
        image.fill(color)
        super().__init__(image, pos, size, size, transparency=128, *groups)
