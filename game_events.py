from utils.events import BaseEvent
from utils.scene import Scene
from event_types import SCENECHANGEEVENT


class SceneChangeEvent(BaseEvent):
    def __init__(self, scene) -> None:
        self.scene = scene
        super().__init__()

    @property
    def event_type(self):
        return SCENECHANGEEVENT

    def _get_kwargs(self):
        return {"scene": self.scene}
