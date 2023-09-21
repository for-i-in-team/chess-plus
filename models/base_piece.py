from __future__ import annotations
from abc import ABC, abstractmethod, abstractproperty
from typing import TYPE_CHECKING

from game_events import ChessPieceMoveEvent, ChessPieceTakeEvent
from utils.base import Coordinate

if TYPE_CHECKING:
    from models.board import ChessSquare, ChessBoard


class PieceColor(ABC):
    @abstractproperty
    def color_name(self) -> str:
        pass

    @abstractproperty
    def rgb(self) -> tuple[int, int, int]:
        pass

    @abstractproperty
    def move_direction(self) -> Coordinate:
        pass

    def __eq__(self, __value: object) -> bool:
        if isinstance(__value, PieceColor):
            return self.color_name == __value.color_name
        return super().__eq__(__value)


class White(PieceColor):
    @property
    def color_name(self) -> str:
        return "white"

    @property
    def rgb(self) -> tuple[int, int, int]:
        return (255, 255, 255)

    @property
    def move_direction(self) -> Coordinate:
        return Coordinate(0, 1)


class Black(PieceColor):
    @property
    def color_name(self) -> str:
        return "black"

    @property
    def rgb(self) -> tuple[int, int, int]:
        return (0, 0, 0)

    @property
    def move_direction(self) -> Coordinate:
        return Coordinate(0, -1)


class ChessPiece(ABC):
    def __init__(self, board: ChessBoard, color: PieceColor) -> None:
        self.board: ChessBoard = board
        self.color: PieceColor = color

    @abstractproperty
    def name(self) -> str:
        pass

    @abstractproperty
    def color(self) -> PieceColor:
        pass

    @abstractproperty
    def position(self) -> ChessSquare:
        pass

    @abstractproperty
    def point_value(self) -> int:
        pass

    def move(self, current_square: ChessSquare, new_square: ChessSquare):
        if new_square in self.get_valid_moves(current_square):
            self._position = new_square
            current_square.piece = None
            new_square.piece = self
            ChessPieceMoveEvent(current_square, new_square, self).fire()
        else:
            raise InvalidMoveError(
                f"Invalid move {current_square} -> {new_square}. Valid moves are {self.get_valid_moves(current_square)}"
            )

    @abstractmethod
    def get_valid_moves(self, current_square: ChessSquare):
        pass

    def take(self, current_square: ChessSquare, new_square: ChessSquare):
        if new_square in self.get_valid_takes(current_square):
            taken_piece = new_square.piece
            if taken_piece is None:
                raise InvalidMoveError(
                    f"Invalid take {current_square} -> {new_square}, no piece at destination! Valid takes are {self.get_valid_takes(current_square)}"
                )
            self._position = new_square
            current_square.piece = None
            new_square.piece = self
            ChessPieceTakeEvent(current_square, new_square, self, taken_piece).fire()
        else:
            raise InvalidMoveError(
                f"Invalid take {current_square} -> {new_square}. Valid takes are {self.get_valid_moves(current_square)}"
            )

    @abstractmethod
    def get_valid_takes(self, current_square: ChessSquare):
        pass

    def where_unoccupied(self, squares: list[ChessSquare]) -> list[ChessSquare]:
        return [square for square in squares if square.piece is None]


class InvalidMoveError(Exception):
    pass
