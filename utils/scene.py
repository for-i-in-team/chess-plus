from typing import TYPE_CHECKING
from abc import ABC

if TYPE_CHECKING:
    from utils.base import GameObject


class Scene(ABC):
    def __init__(self) -> None:
        self.objects: list[GameObject] = []

    def update(self) -> None:
        for obj in self.objects:
            obj.update()

    def draw(self, screen) -> None:
        for obj in self.objects:
            obj.draw(screen)

    def handle_event(self, event) -> None:
        for obj in self.objects:
            obj.handle_event(event)
