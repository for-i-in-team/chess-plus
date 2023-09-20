from pygame import Surface
from pygame.font import SysFont
from models.base_piece import ChessPiece, Black, White

cache = {}


def get_piece(piece: ChessPiece) -> Surface:
    key = f"{type(piece)}{piece.color}"
    if key not in cache:
        main = piece.color
        secondary = Black() if main.color_name == White().color_name else White()
        cache[key]: Surface = SysFont("Arial", 40).render(
            str(piece.name)[0], True, main.rgb, secondary.rgb
        )
    return cache[key]
