from __future__ import annotations
from typing import TYPE_CHECKING

from utils.events import BaseEvent
from event_types import SCENECHANGEEVENT, CHESSSQUARECLICKEVENT

if TYPE_CHECKING:
    from utils.scene import Scene
    from view.board import ChessSquareView


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
