from __future__ import annotations
from typing import TYPE_CHECKING

from pygame import Surface
from pygame.font import SysFont
from utils.base import Sprite

if TYPE_CHECKING:
    from pygame.sprite import _Group
    from utils.base import Coordinate


class Button(Sprite):
    def __init__(
        self,
        image: Surface | str,
        on_press: function,
        pos: Coordinate = None,
        *groups: _Group,
    ) -> None:
        if isinstance(image, str):
            image = SysFont("Arial", 20).render(image, True, (0, 0, 0))
        super().__init__(image, pos=pos, on_left_click=on_press, *groups)
