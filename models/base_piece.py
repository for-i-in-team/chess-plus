from __future__ import annotations
from abc import ABC, abstractmethod, abstractproperty
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from models.board import ChessSquare, ChessBoard
    from utils.base import Coordinate


class PieceColor(ABC):
    @abstractproperty
    def color(self) -> str:
        pass

    @abstractproperty
    def move_direction(self) -> Coordinate:
        pass


class White(PieceColor):
    @property
    def color(self) -> str:
        return "white"

    @property
    def move_direction(self) -> Coordinate:
        return Coordinate(1, 0)


class Black(PieceColor):
    @property
    def color(self) -> str:
        return "black"

    @property
    def move_direction(self) -> Coordinate:
        return Coordinate(-1, 0)


class ChessPiece(ABC):
    def __init__(self, board: ChessBoard, color: PieceColor) -> None:
        self.board: ChessBoard = board
        self.color: PieceColor = color

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
