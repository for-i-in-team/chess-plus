from __future__ import annotations
from typing import TYPE_CHECKING

import pygame
from pygame.event import Event

from event_types import CHESSSQUARECLICKEVENT
from game_events import ChessSquareClickEvent
from utils.base import ParentObject, Sprite, Coordinate
from view.piece import PieceView
from models.base_piece import ChessPiece
from view.square_selection import SquareSelection

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
        self.square_selection: SquareSelection | None = None
        self.board: ChessBoard = board
        self.pos: Coordinate = pos
        if size is None:
            max_size = pygame.display.get_window_size()[1] * 0.8
            size: Coordinate = Coordinate(max_size, max_size)

        self.size = size

        square_size = int(self.size.x / max(board.size.x, board.size.y))
        top_left = self.top_left
        for row in self.board.squares:
            for square in row:
                self.children.append(
                    ChessSquareView(
                        square,
                        square_size,
                        (top_left + square.coords * square_size) + int(square_size / 2),
                    )
                )

    @property
    def top_left(self):
        return Coordinate(
            self.pos.x - int(self.size.x / 2), self.pos.y - int(self.size.y / 2)
        )

    def spawn_selection_display(self, square: ChessSquareView):
        if self.square_selection is not None:
            self.children.remove(self.square_selection)
            self.square_selection = None
        self.square_selection = SquareSelection(self, square)
        self.children.append(self.square_selection)

    def handle_event(self, event: Event) -> None:
        if event.type == CHESSSQUARECLICKEVENT:
            self.spawn_selection_display(event.square)
        return super().handle_event(event)


class ChessSquareView(Sprite):
    def __init__(self, square: ChessSquare, size: int, pos: Coordinate) -> None:
        self.square: ChessSquare = square
        self.size = size
        self.piece_view: PieceView | None = (
            PieceView(square.piece, (int(size / 2), int(size / 2)), size * 8 / 10)
            if square.piece is not None
            else None
        )
        super().__init__(
            self.get_image(), pos, on_left_click=ChessSquareClickEvent(self).fire
        )

    def set_piece(self, piece: ChessPiece):
        if self.piece_view is None or piece != self.piece_view.piece:
            if piece is None:
                self.piece_view = None
            else:
                self.piece_view = PieceView(piece, self.pos, self.size)
        self.image = self.get_image()

    def get_image(self):
        image = pygame.Surface((self.size, self.size))
        image.fill(self.square.color.value)
        if self.piece_view is not None:
            self.piece_view.draw(image)
        return image
