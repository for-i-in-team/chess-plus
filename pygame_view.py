from __future__ import annotations
from typing import TYPE_CHECKING

import pygame

from events import SCENECHANGEEVENT

if TYPE_CHECKING:
    from utils.scene import Scene
    from pygame import Surface
    from pygame.time import Clock


class PygameView:
    def __init__(self, scene: Scene):
        self.screen: Surface = pygame.display.set_mode((1280, 720))
        self.clock: Clock = pygame.time.Clock()
        self.fps: int = 60
        self.scene: Scene = scene

    def loop(self):
        while True:
            self.screen.fill((63, 66, 69))

            for event in pygame.event.get():
                self.scene.handle_event(event)
                if event.type == pygame.QUIT:
                    pygame.quit()
                    return
                if event.type == SCENECHANGEEVENT:
                    self.scene = event.scene

            self.scene.update()

            self.scene.draw(self.screen)

            pygame.display.update()
            self.clock.tick(self.fps)
