#!/usr/bin/env python3
"""Preserve GTK preferences while matching the selected desktop appearance."""
import configparser
from pathlib import Path
import sys

root, mode = Path(sys.argv[1]), sys.argv[2]
for version in ('gtk-3.0', 'gtk-4.0'):
    path = root/version/'settings.ini'
    config = configparser.ConfigParser(interpolation=None)
    config.optionxform = str
    config.read(path)
    if not config.has_section('Settings'):
        config.add_section('Settings')
    config['Settings']['gtk-application-prefer-dark-theme'] = 'true' if mode == 'dark' else 'false'
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix('.ini.tmp')
    with temporary.open('w') as output:
        config.write(output, space_around_delimiters=False)
    temporary.replace(path)
