import pygame

from models.board import ChessBoard
from view.board import ChessBoardView
from utils.base import Coordinate
from utils.scene import Scene


class PlayChess(Scene):
    def __init__(self) -> None:
        super().__init__()
        board = ChessBoard(8)
        self.objects.append(
            ChessBoardView(
                board,
                Coordinate(
                    pygame.display.get_window_size()[0] / 2,
                    pygame.display.get_window_size()[1] / 2,
                ),
            )
        )
