from abc import ABC, abstractmethod, abstractproperty

from pygame.event import Event, post
from pygame import USEREVENT

from utils.scene import Scene

increment = 0


def new_event_type():
    global increment
    increment += 1
    return USEREVENT + increment


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
