from abc import ABC, abstractmethod, abstractproperty

from pygame.event import Event, post
from pygame import USEREVENT

from utils.scene import Scene

SCENECHANGEEVENT = USEREVENT + 1


class BaseEvent(ABC):
    @abstractproperty
    def event_type(self):
        pass

    @abstractmethod
    def _get_kwargs(self):
        pass

    def fire(self):
        event = Event(self.event_type, self._get_kwargs())
        post(event)


class SceneChangeEvent(BaseEvent):
    def __init__(self, scene) -> None:
        self.scene = scene
        super().__init__()

    @property
    def event_type(self):
        return SCENECHANGEEVENT

    def _get_kwargs(self):
        return {"scene": self.scene}
