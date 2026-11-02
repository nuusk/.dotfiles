#!/usr/bin/env python3
"""Render an accent from the original mode palette, never from generated files."""
import json
from pathlib import Path
import re
import sys

source, destination, mode, accent = sys.argv[1:]
source, destination = Path(source), Path(destination)
palettes = json.loads((Path(__file__).with_name('accents.json')).read_text())
original, selected = palettes['green'][mode], palettes[accent][mode]
replacements = {}
for old, new in zip(original, selected):
    replacements[old] = new
    old_rgb = tuple(int(old[i:i+2], 16) for i in (0, 2, 4))
    new_rgb = tuple(int(new[i:i+2], 16) for i in (0, 2, 4))
    replacements[', '.join(map(str, old_rgb))] = ', '.join(map(str, new_rgb))
    replacements[','.join(map(str, old_rgb))] = ','.join(map(str, new_rgb))
pattern = re.compile('|'.join(re.escape(key) for key in sorted(replacements, key=len, reverse=True)))
destination.mkdir(parents=True, exist_ok=True)
for file in source.iterdir():
    if file.is_file():
        (destination/file.name).write_text(pattern.sub(lambda match: replacements[match[0]], file.read_text()))
alpha = 'aa' if mode == 'dark' else 'dd'
(destination/'accent.lua').write_text(
    'return { "rgba(' + selected[0] + alpha + ')", "rgba(' + selected[1] + alpha + ')" }\n'
)
