"""Custom kitty tab bar.

Layout:  [cwd]        [tab] [tab] [tab]        [hostname] [clock]

Put this file at ~/.config/kitty/tab_bar.py and set `tab_bar_style custom`.
"""

from __future__ import annotations

import datetime
import socket
from contextlib import nullcontext
from dataclasses import dataclass, field
from functools import cache, wraps
from pathlib import Path
from typing import Callable

from kitty.fast_data_types import Screen, add_timer, get_boss, get_options, wcswidth
from kitty.tab_bar import (
    CellRange,
    DrawData,
    ExtraData,
    TabAccessor,
    TabBar,
    TabBarData,
    TabExtent,
    as_rgb,
)
from kitty.utils import color_as_int

try:
    from kitty.child import cached_process_data
except ImportError:
    cached_process_data = nullcontext

# --------------------------------------------------------------------------- #
# Config
# --------------------------------------------------------------------------- #

MAX_PATH_DEPTH = 3
CLOCK_FORMAT = "%H:%M"
GAP = 1
LEFT_MARGIN = 0
RIGHT_MARGIN = 0

# Nerd Font glyphs (Solid Style)
LEFT_CAP = "\ue0b6"  # 
RIGHT_CAP = "\ue0b4"  # 
SEPARATOR = "\ue0b0"  # 
FOLDER_ICON = "\U000f024b "  # 󰉋
CLOCK_ICON = "\U000f0150 "  # 󰅐
HOST_ICON = "\U000f018d "  # 󰆍

# --------------------------------------------------------------------------- #
# Colors
# --------------------------------------------------------------------------- #

_opts = get_options()


def _theme_color(name: str, fallback: int) -> int:
    value = getattr(_opts, name, None)
    return as_rgb(color_as_int(value) if value is not None else fallback)


DEFAULT = 0
BG = _theme_color("color19", 0x3C3836)
FG = _theme_color("color15", 0xEBDBB2)
COLOR_TAB = _theme_color("color3", 0xD79921)
COLOR_TAB_ACTIVE = _theme_color("color5", 0xB16286)
COLOR_CWD = _theme_color("color4", 0x458588)
COLOR_INFO = _theme_color("color4", 0x458588)

# --------------------------------------------------------------------------- #
# Text helpers
# --------------------------------------------------------------------------- #

SourceFn = Callable[["TabBarData | None"], "str | None"]
FitFn = Callable[[str, int], "str | None"]


@cache
def _home() -> Path:
    return Path.home()


def _ellipsize(text: str, width: int) -> str:
    if wcswidth(text) <= width:
        return text
    if width < 2:
        return ""
    kept: list[str] = []
    used = 0
    for char in text:
        cw = wcswidth(char)
        if used + cw > width - 1:
            break
        kept.append(char)
        used += cw
    return "".join(kept) + "…"


def _shorten_path(raw: str, max_width: int) -> str | None:
    if not raw:
        return None

    path = Path(raw)
    home = _home()
    if path.is_relative_to(home):
        head, rest = "~", list(path.relative_to(home).parts)
    else:
        head, rest = "", list(path.parts[1:] if path.is_absolute() else path.parts)

    def render(tail_len: int) -> str:
        dropped = len(rest) > tail_len
        segments = ([".."] if dropped else []) + rest[len(rest) - tail_len :]
        if not segments:
            return head or "/"
        return "/".join([head, *segments])

    depth = min(len(rest), MAX_PATH_DEPTH)
    candidates = [render(n) for n in range(depth, 0, -1)] if depth else [render(0)]
    if rest:
        candidates.append(rest[-1])
    return next((c for c in candidates if wcswidth(c) <= max_width), None)


# --------------------------------------------------------------------------- #
# Cell
# --------------------------------------------------------------------------- #


def _paint(screen: Screen, text: str, fg: int, bg: int, bold: bool = False) -> None:
    cursor = screen.cursor
    cursor.fg = fg
    cursor.bg = bg
    cursor.bold = bold
    screen.draw(text)


def _reset_style(screen: Screen) -> None:
    cursor = screen.cursor
    cursor.fg = DEFAULT
    cursor.bg = DEFAULT
    cursor.bold = False
    cursor.italic = False
    cursor.dim = False


_UNSET = object()


@cache
def _metrics(icon: str) -> tuple[int, int]:
    overhead = wcswidth(LEFT_CAP + icon + SEPARATOR + RIGHT_CAP) + 1
    return overhead, wcswidth(LEFT_CAP + icon + RIGHT_CAP)


@dataclass
class Cell:
    icon: str
    source: SourceFn
    fit: FitFn
    tab: TabBarData | None = None
    color: int = COLOR_TAB
    bg: int = BG
    fg: int = FG

    _raw: object = field(init=False, repr=False, default=_UNSET)
    _texts: dict[int, str | None] = field(init=False, repr=False, default_factory=dict)
    _overhead: int = field(init=False, repr=False, default=0)
    _collapsed_width: int = field(init=False, repr=False, default=0)

    def __post_init__(self) -> None:
        self._overhead, self._collapsed_width = _metrics(self.icon)

    def _text(self, max_size: int) -> str | None:
        budget = max_size - self._overhead
        if budget in self._texts:
            return self._texts[budget]
        if self._raw is _UNSET:
            self._raw = self.source(self.tab)
        text = None if self._raw is None else self.fit(self._raw, budget)  # type: ignore[arg-type]
        self._texts[budget] = text
        return text

    def width(self, max_size: int) -> int:
        text = self._text(max_size)
        if text is None:
            return 0
        if text == "":
            return self._collapsed_width
        return self._overhead + wcswidth(text)

    def draw(self, screen: Screen, max_size: int) -> None:
        text = self._text(max_size)
        if text is None:
            return

        _reset_style(screen)
        _paint(screen, LEFT_CAP, self.color, DEFAULT)
        _paint(screen, self.icon, self.bg, self.color, bold=True)
        if text == "":
            _paint(screen, RIGHT_CAP, self.color, DEFAULT)
        else:
            _paint(screen, SEPARATOR, self.color, self.bg)
            _paint(screen, f" {text}", self.fg, self.bg)
            _paint(screen, RIGHT_CAP, self.bg, DEFAULT)
        _reset_style(screen)


# --------------------------------------------------------------------------- #
# Text providers
# --------------------------------------------------------------------------- #


def _tab_source(tab: TabBarData | None) -> str | None:
    if tab is None:
        return None
    title = tab.title or ""
    if title.startswith("#"):
        return title[1:]
    return TabAccessor(tab.tab_id).active_exe or ""


def _cwd_source(tab: TabBarData | None) -> str | None:
    """Return active working directory; fall back to '~' so the cell always renders."""
    if tab is None:
        return None
    cwd = TabAccessor(tab.tab_id).active_wd
    return cwd if cwd else "~"


@cache
def _hostname_source(tab: TabBarData | None) -> str | None:
    return socket.gethostname()


def _clock_source(tab: TabBarData | None) -> str | None:
    return datetime.datetime.now().strftime(CLOCK_FORMAT)


def _fit_clock(text: str, width: int) -> str | None:
    return text if wcswidth(text) <= width else None


def _fit_hostname(text: str, width: int) -> str | None:
    return _ellipsize(text, width) or None


# --------------------------------------------------------------------------- #
# Layout
# --------------------------------------------------------------------------- #

Plan = list[tuple[Cell, int]]


def _plan_width(plan: Plan) -> int:
    return sum(cell.width(size) for cell, size in plan) + GAP * (len(plan) - 1)


def _plan_center(cells: list[Cell], active: int, columns: int) -> tuple[Plan, int]:
    usable = columns - LEFT_MARGIN - RIGHT_MARGIN
    plans: list[Plan] = [
        [(cell, usable) for cell in cells],
        [(cell, usable if i == active else 0) for i, cell in enumerate(cells)],
        [(cell, 0) for cell in cells],
        [(cells[active], usable)],
    ]
    for plan in plans:
        if _plan_width(plan) <= usable:
            return plan, _plan_width(plan)

    fallback: Plan = [(cells[active], 0)]
    return fallback, _plan_width(fallback)


def _draw_center(screen: Screen, plan: Plan) -> list[TabExtent]:
    extents: list[TabExtent] = []
    for i, (cell, size) in enumerate(plan):
        if i:
            screen.draw(" " * GAP)
        start = screen.cursor.x
        cell.draw(screen, size)
        end = screen.cursor.x - 1
        if cell.tab is not None and end >= start:
            extents.append(TabExtent(cell.tab.tab_id, CellRange(start, end)))
    return extents


def _draw_right(screen: Screen, active_tab: TabBarData | None) -> None:
    available = screen.columns - screen.cursor.x - GAP - RIGHT_MARGIN
    clock = Cell(CLOCK_ICON, _clock_source, _fit_clock, color=COLOR_INFO)
    host = Cell(
        HOST_ICON, _hostname_source, _fit_hostname, active_tab, color=COLOR_INFO
    )

    clock_width = clock.width(available)
    host_max = max(0, available - clock_width - GAP)
    host_width = host.width(host_max)

    total = clock_width + (host_width + GAP if host_width else 0)
    if total == 0:
        return

    padding = max(0, screen.columns - RIGHT_MARGIN - screen.cursor.x - total)
    screen.draw(" " * padding)
    if host_width:
        host.draw(screen, host_max)
        screen.draw(" " * GAP)
    clock.draw(screen, available)


def _draw_bar(screen: Screen, cells: list[Cell]) -> list[TabExtent]:
    active = next((i for i, c in enumerate(cells) if c.tab and c.tab.is_active), 0)
    active_tab = cells[active].tab

    plan, width = _plan_center(cells, active, screen.columns)
    usable = screen.columns - LEFT_MARGIN - RIGHT_MARGIN
    center_offset = max(0, (usable - width) // 2)
    start = LEFT_MARGIN + center_offset

    # --- Left: margin + cwd + gap ---
    screen.cursor.x = 0

    # 【修复】用 CWD 的背景色填充左边距，而非 DEFAULT
    # 避免 LEFT_CAP 的 bg=DEFAULT 被终端解析为异色方块
    _paint(screen, " " * LEFT_MARGIN, COLOR_CWD, COLOR_CWD)

    cwd = Cell(FOLDER_ICON, _cwd_source, _shorten_path, active_tab, color=COLOR_CWD)
    cwd_max = max(0, start - LEFT_MARGIN - GAP)
    cwd.draw(screen, cwd_max)

    _reset_style(screen)
    screen.draw(" " * max(0, start - screen.cursor.x))

    # --- Center: tabs ---
    extents = _draw_center(screen, plan)

    # --- Right: hostname + clock + margin ---
    _draw_right(screen, active_tab)
    return extents


# --------------------------------------------------------------------------- #
# Clock timer
# --------------------------------------------------------------------------- #

_timer_id: int | None = None
_tab_cells: list[Cell] = []
_pending_extents: list[TabExtent] | None = None


def _clock_delay() -> float:
    now = datetime.datetime.now()
    if "%S" in CLOCK_FORMAT:
        return 1.0 - now.microsecond / 1e6 + 0.02
    return 60.0 - now.second - now.microsecond / 1e6 + 0.02


def _arm_clock_timer() -> None:
    global _timer_id
    _timer_id = add_timer(_on_clock_tick, _clock_delay(), False)


def _on_clock_tick(_id: int) -> None:
    _arm_clock_timer()
    boss = get_boss()
    if boss is None:
        return
    for tm in boss.all_tab_managers:
        tm.mark_tab_bar_dirty()


# --------------------------------------------------------------------------- #
# Click region patching
# --------------------------------------------------------------------------- #

_WRAPPED = "_tab_bar_wrapped"
_DRAW_METHODS = ("update", "draw", "layout_and_draw", "_draw_tab_bar")


def _consume_pending_extents() -> list[TabExtent] | None:
    global _pending_extents
    extents, _pending_extents = _pending_extents, None
    return extents


def _patch_tab_bar() -> None:
    def _wrap(method):
        @wraps(method)
        def wrapper(self, *args, **kwargs):
            global _pending_extents
            _pending_extents = None
            result = method(self, *args, **kwargs)
            extents = _consume_pending_extents()
            if extents and not getattr(self, "is_vertical", False):
                self.tab_extents = tuple(extents)
            return result

        setattr(wrapper, _WRAPPED, True)
        return wrapper

    for name in _DRAW_METHODS:
        original = getattr(TabBar, name, None)
        if original is None or getattr(original, _WRAPPED, False):
            continue
        setattr(TabBar, name, _wrap(original))


_patch_tab_bar()


# --------------------------------------------------------------------------- #
# kitty entry point
# --------------------------------------------------------------------------- #


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global _pending_extents

    if _timer_id is None:
        _arm_clock_timer()

    if getattr(extra_data, "for_layout", False):
        return screen.cursor.x

    if index == 1:
        _tab_cells.clear()

    color = COLOR_TAB_ACTIVE if tab.is_active else COLOR_TAB
    _tab_cells.append(Cell(str(index), _tab_source, _ellipsize, tab, color=color))

    if is_last:
        try:
            with cached_process_data():
                _pending_extents = _draw_bar(screen, _tab_cells)
        finally:
            _tab_cells.clear()

    return screen.cursor.x
