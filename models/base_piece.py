from __future__ import annotations
from abc import ABC, abstractmethod, abstractproperty
from typing import TYPE_CHECKING

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

    @abstractmethod
    def move(self, current_square: ChessSquare, new_square: ChessBoard):
        pass

    @abstractmethod
    def get_valid_moves(self, current_square: ChessSquare):
        pass

    @abstractmethod
    def take(self, current_square: ChessSquare, new_square: ChessBoard):
        pass

    @abstractmethod
    def get_valid_takes(self, current_square: ChessSquare):
        pass

    def where_unoccupied(self, squares: list[ChessSquare]) -> list[ChessSquare]:
        return [square for square in squares if square.piece is None]


class InvalidMoveError(Exception):
    pass
