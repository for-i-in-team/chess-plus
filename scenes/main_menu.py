from events import SceneChangeEvent
from utils.scene import Scene
from scenes.play_chess import PlayChess
from utils.interface import Button


class MainMenu(Scene):
    def __init__(self) -> None:
        super().__init__()
        self.objects.append(Button("Play", self.play, pos=(400, 300)))

    def play(self):
        SceneChangeEvent(PlayChess()).fire()
