from pygame.event import Event, post
from pygame import USEREVENT

from utils.scene import Scene

SCENECHANGEEVENT = USEREVENT + 1


def scene_change(scene: Scene) -> Event:
    event = Event(SCENECHANGEEVENT, scene=scene)
    post(event)
