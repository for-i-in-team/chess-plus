from __future__ import annotations
from typing import TYPE_CHECKING
from abc import ABC

from pygame.sprite import Sprite as BaseSprite
from pygame import transform, MOUSEBUTTONDOWN, MOUSEBUTTONUP

if TYPE_CHECKING:
    from pygame import Surface, Rect
    from pygame.sprite import _Group
    from pygame.event import Event

LEFTMOUSE = 1
RIGHTMOUSE = 3


class GameObject(BaseSprite, ABC):
    def handle_event(self, event: Event) -> None:
        "Base function for handling events, will simply pass unless overridden by a child class"
        pass

    def update(self) -> None:
        "Base function for updating the object on each frame, will simply pass unless overridden by a child class"
        pass

    def draw(self, surface: Surface) -> None:
        "Base function for drawing the object on each frame, will simply pass unless overridden by a child class"
        pass


class ParentObject(GameObject, ABC):
    def __init__(self, *groups: _Group) -> None:
        super().__init__(*groups)
        self.children: list[GameObject] = []

    def handle_event(self, event: Event) -> None:
        for child in self.children:
            child.handle_event(event)

    def update(self) -> None:
        for child in self.children:
            child.update()

    def draw(self, surface: Surface) -> None:
        for child in self.children:
            child.draw(surface)


class Sprite(GameObject, ABC):
    def __init__(
        self,
        image: Surface,
        pos: Coordinate | None = None,
        height: int = None,
        width: int = None,
        rotation: int = 0,
        transparency: float = 255,
        flip: bool = False,
        on_left_click: callable[Event] = None,
        on_right_click: callable[Event] = None,
        *groups: _Group,
    ) -> None:
        super().__init__(*groups)
        self._pos: Coordinate = pos or Coordinate(0, 0)
        self._image: Surface = image
        self._height: int | None = height
        self._width: int | None = width
        self._rotation: int = rotation
        self._transparency: float = transparency
        self._flip: bool = flip
        self._image_needs_transform: bool = True
        self._transformed_image: Surface = None
        self._rect_needs_update: bool = True
        self._rect: Rect = None

        self._left_mouse_down: bool = False
        self._right_mouse_down: bool = False
        self.on_left_click: function = on_left_click
        self.on_right_click: function = on_right_click

    @property
    def pos(self) -> Coordinate:
        return self._pos

    @pos.setter
    def pos(self, value: Coordinate):
        if value != self._pos:
            self._pos = value
            self._rect_needs_update = True

    @property
    def height(self) -> int | None:
        return self._height

    @height.setter
    def height(self, value: int):
        if value != self._height:
            self._height = value
            self._image_needs_transform = True

    @property
    def width(self) -> int | None:
        return self._width

    @width.setter
    def width(self, value: int):
        if value != self._width:
            self._width = value
            self._image_needs_transform = True

    @property
    def rotation(self) -> int:
        return self._rotation

    @rotation.setter
    def rotation(self, value: int):
        if value != self._rotation:
            self._rotation = value
            self._image_needs_transform = True

    @property
    def transparency(self) -> float:
        return self._transparency

    @transparency.setter
    def transparency(self, value: float):
        if value != self._transparency:
            self._transparency = value
            self._image_needs_transform = True

    @property
    def flip(self) -> bool:
        return self._flip

    @flip.setter
    def flip(self, value: bool):
        if value != self._flip:
            self._flip = value
            self._image_needs_transform = True

    def transform_image(self) -> None:
        new_image = self._image.copy()
        if self._transparency != 255:
            new_image.set_alpha(self._transparency)
        new_image = self.scale_image(new_image)
        if self._rotation != 0:
            new_image = transform.rotate(new_image, self._rotation)
        if self._flip:
            new_image = transform.flip(new_image, True, False)
        self._transformed_image = new_image
        self.update_rect()

    def scale_image(self, new_image: Surface) -> Surface:
        width = self._width
        height = self._height
        if width is None and height is None:
            return new_image

        if width is None:
            width = new_image.get_width() * self._height / new_image.get_height()
        elif height is None:
            height = new_image.get_height() * self._width / new_image.get_width()

        if width != new_image.get_width() or height != new_image.get_height():
            return transform.scale(new_image, (width, height))
        else:
            return new_image

    def update_rect(self) -> None:
        self._rect = self._transformed_image.get_rect(
            centerx=int(self.pos[0]), centery=int(self.pos[1])
        )

    def touches(self, pos: Coordinate) -> bool:
        if self._rect == None:
            self.update_rect()
        return self._rect.collidepoint(pos)

    def check_clicks(self, event: Event) -> None:
        if event.type == MOUSEBUTTONDOWN and self.touches(event.pos):
            self._left_mouse_down = event.button == LEFTMOUSE
            self._right_mouse_down = event.button == RIGHTMOUSE
        elif event.type == MOUSEBUTTONUP:
            if event.button == LEFTMOUSE and self._left_mouse_down:
                self._left_mouse_down = False
                if self.on_left_click is not None:
                    self.on_left_click()
            elif event.button == RIGHTMOUSE and self._right_mouse_down:
                self._right_mouse_down = False
                if self.on_right_click is not None:
                    self.on_right_click()

    def draw(self, surface: Surface) -> None:
        if self._image_needs_transform:
            self.transform_image()
            self._image_needs_transform = False

        surface.blit(self._transformed_image, self._rect)

    def handle_event(self, event: Event) -> None:
        self.check_clicks(event)


class Coordinate:
    def __init__(self, x, y) -> None:
        self.x = x
        self.y = y

    def __getitem__(self, index):
        return (self.x, self.y)[index]

    def __add__(self, other):
        if isinstance(other, int):
            return Coordinate(self.x + other, self.y + other)
        if isinstance(other, Coordinate):
            return Coordinate(self.x + other.x, self.y + other.y)
        else:
            return NotImplemented

    def __sub__(self, other):
        if isinstance(other, int):
            return Coordinate(self.x - other, self.y - other)
        if isinstance(other, Coordinate):
            return Coordinate(self.x - other.x, self.y - other.y)
        else:
            return NotImplemented

    def __iadd__(self, other):
        if isinstance(other, int):
            self.x += other
            self.y += other
        if isinstance(other, Coordinate):
            self.x += other.x
            self.y += other.y
        else:
            return NotImplemented

    def __isub__(self, other):
        if isinstance(other, int):
            self.x -= other
            self.y -= other
        if isinstance(other, Coordinate):
            self.x -= other.x
            self.y -= other.y
        else:
            return NotImplemented

    def __mul__(self, other):
        if isinstance(other, int):
            return Coordinate(self.x * other, self.y * other)
        else:
            return NotImplemented

    def __rmul__(self, other):
        if isinstance(other, int):
            return Coordinate(other * self.x, other * self.y)
        else:
            return NotImplemented

    def __neg__(self):
        return Coordinate(-self.x, -self.y)

    def __abs__(self):
        return self.x**2 + self.y**2

    def __invert__(self):
        return Coordinate(self.y, self.x)

    def __str__(self) -> str:
        return f"({self.x}, {self.y})"

    def __repr__(self) -> str:
        return f"Coordinate({self.x}, {self.y})"
