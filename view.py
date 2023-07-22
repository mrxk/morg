#!/usr/lib/rich/bin/python3

import sys
from rich import box
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel
from rich.style import Style

page = False
path = sys.argv[1]

if path == "-p":
  page = True
  path = sys.argv[2]

with open(path) as f:
  markdown = Markdown(f.read(), hyperlinks=False)

box = Panel(markdown, getattr(box, "SQUARE"))
c = Console(force_terminal=True, soft_wrap=False)

if page == True:
  with c.pager(styles=True):
    c.print(box)
else:
  c.print(box)
