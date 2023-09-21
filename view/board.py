from __future__ import annotations
from typing import TYPE_CHECKING

import pygame
from pygame import Surface
from pygame.event import Event

from event_types import CHESSSQUARECLICKEVENT, CHESSPIECEMOVEEVENT, CHESSPIECETAKEEVENT
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
        self.square_selection: SquareSelection | None = SquareSelection(self, None)
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

    def handle_square_click(self, square: ChessSquareView):
        self.square_selection.set_square(square)

    def handle_event(self, event: Event) -> None:
        if event.type == CHESSSQUARECLICKEVENT:
            self.handle_square_click(event.square)
        return super().handle_event(event)

    def draw(self, surface: Surface) -> None:
        super().draw(surface)
        self.square_selection.draw(surface)


class ChessSquareView(Sprite):
    def __init__(self, square: ChessSquare, size: int, pos: Coordinate) -> None:
        self.square: ChessSquare = square
        self.size: Coordinate = size
        self.piece_view: PieceView | None = None
        super().__init__(
            self.get_image(), pos, on_left_click=ChessSquareClickEvent(self).fire
        )
        self.set_piece(self.square.piece)

    def set_piece(self, piece: ChessPiece):
        if self.piece_view is None or piece != self.piece_view.piece:
            if piece is None:
                self.piece_view = None
            else:
                self.piece_view = PieceView(
                    self.square.piece,
                    (int(self.size / 2), int(self.size / 2)),
                    self.size * 8 / 10,
                )
        self.image = self.get_image()

    def get_image(self):
        image = pygame.Surface((self.size, self.size))
        image.fill(self.square.color.value)
        if self.piece_view is not None:
            self.piece_view.draw(image)
        return image

    def handle_event(self, event: Event) -> None:
        if event.type == CHESSPIECEMOVEEVENT:
            if event.old_square == self.square:
                self.set_piece(None)
            if event.new_square == self.square:
                self.set_piece(event.new_square.piece)
        if event.type == CHESSPIECETAKEEVENT:
            if event.old_square == self.square:
                self.set_piece(None)
            if event.new_square == self.square:
                self.set_piece(event.new_square.piece)
            if (
                self.piece_view is not None
                and event.taken_piece == self.piece_view.piece
            ):
                self.set_piece(None)

        return super().handle_event(event)
