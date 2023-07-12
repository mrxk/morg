#!/usr/lib/rich/bin/python3

import sys
from rich import box
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel
from rich.style import Style

with open(sys.argv[1]) as f:
  markdown = Markdown(f.read(), hyperlinks=False)

box = Panel(markdown, getattr(box, "SQUARE"))
Console(force_terminal=True, soft_wrap=True).print(box)
