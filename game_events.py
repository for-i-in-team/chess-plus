from __future__ import annotations
from typing import TYPE_CHECKING

from utils.events import BaseEvent
from event_types import (
    SCENECHANGEEVENT,
    CHESSSQUARECLICKEVENT,
    CHESSPIECEMOVEEVENT,
    CHESSPIECETAKEEVENT,
)

if TYPE_CHECKING:
    from utils.scene import Scene
    from view.board import ChessSquareView
    from models.board import ChessSquare
    from models.base_piece import ChessPiece


class SceneChangeEvent(BaseEvent):
    def __init__(self, scene: Scene) -> None:
        self.scene = scene
        super().__init__()

    @property
    def event_type(self):
        return SCENECHANGEEVENT

    def _get_kwargs(self):
        return {"scene": self.scene}


class ChessSquareClickEvent(BaseEvent):
    def __init__(self, square: ChessSquareView) -> None:
        self.square = square
        super().__init__()

    @property
    def event_type(self):
        return CHESSSQUARECLICKEVENT

    def _get_kwargs(self):
        return {"square": self.square}


class ChessPieceMoveEvent(BaseEvent):
    def __init__(
        self, old_square: ChessSquare, new_square: ChessSquare, piece: ChessPiece
    ) -> None:
        self.old_square = old_square
        self.new_square = new_square
        self.piece = piece
        super().__init__()

    @property
    def event_type(self):
        return CHESSPIECEMOVEEVENT

    def _get_kwargs(self):
        return {
            "old_square": self.old_square,
            "new_square": self.new_square,
            "piece": self.piece,
        }


class ChessPieceTakeEvent(BaseEvent):
    def __init__(
        self,
        old_square: ChessSquare,
        new_square: ChessPiece,
        taking_piece: ChessPiece,
        taken_piece: ChessPiece,
    ) -> None:
        self.old_square = old_square
        self.new_square = new_square
        self.taking_piece = taking_piece
        self.taken_piece = taken_piece
        super().__init__()

    @property
    def event_type(self):
        return CHESSPIECETAKEEVENT

    def _get_kwargs(self):
        return {
            "old_square": self.old_square,
            "new_square": self.new_square,
            "taking_piece": self.taking_piece,
            "taken_piece": self.taken_piece,
        }
