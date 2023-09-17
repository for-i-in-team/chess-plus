from pygame_view import PygameView
from scenes.main_menu import MainMenu
import pygame

if __name__ == "__main__":
    pygame.init()
    starting_scene = MainMenu()
    view = PygameView(starting_scene)
    view.loop()
