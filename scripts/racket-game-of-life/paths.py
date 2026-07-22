"""Shared paths for racket-game-of-life build scripts."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BOOK_SLUG = "racket-game-of-life"
BOOK_MD = ROOT / "manuscript/racket-game-of-life/book.md"
OUT_DIR = ROOT / "output/racket-game-of-life"
ASSETS = ROOT / "assets/epub"
COVER = ROOT / "images/cover.jpg"

TITLE = "Racketで学ぶ生命のゲーム"
SUBTITLE = "関数型プログラミング入門とコンウェイのライフゲーム"
AUTHOR = "陸機雑学ファクトリー / Grok 4.5"
EPUB_BASENAME = "Racketで学ぶ生命のゲーム"

APPENDIX_C_MARKER = "rackunit"

DEFAULT_OUTPUT = {
    "epub-horizontal": OUT_DIR / f"{EPUB_BASENAME}-横書き.epub",
    "epub-vertical": OUT_DIR / f"{EPUB_BASENAME}-縦書き.epub",
    "docx": OUT_DIR / f"{EPUB_BASENAME}.docx",
}
