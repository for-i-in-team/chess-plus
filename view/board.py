from __future__ import annotations
from typing import TYPE_CHECKING

import pygame

from utils.base import ParentObject, Sprite, Coordinate

if TYPE_CHECKING:
    from models.board import ChessBoard, ChessSquare


class ChessBoardView(ParentObject):
    def __init__(
        self,
        board: ChessBoard,
        pos: Coordinate,
        size: Coordinate | None = None,
        *groups,
    ) -> None:
        super().__init__(groups)
        self.board: ChessBoard = board
        self.pos: Coordinate = pos
        if size is None:
            max_size = pygame.display.get_window_size()[1] * 0.8
            size: Coordinate = Coordinate(max_size, max_size)

        self.size = size

        square_size = int(self.size.x / max(board.size.x, board.size.y))
        top_left = self.pos - int(self.size.x / 2)
        for row in self.board.squares:
            for square in row:
                self.children.append(
                    ChessSquareView(
                        square,
                        square_size,
                        (top_left + square.coords * square_size) + int(square_size / 2),
                    )
                )


class ChessSquareView(Sprite):
    def __init__(self, square: ChessSquare, size: int, pos: Coordinate) -> None:
        self.square: ChessSquare = square
        image = pygame.Surface((size, size))
        image.fill(square.color.value)
        super().__init__(image, pos)
