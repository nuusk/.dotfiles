#!/bin/bash

# Take region screenshot, open in swappy for annotation
tmpfile=$(mktemp --suffix .png)
/usr/bin/grim -g "$(slurp)" "$tmpfile" && swappy -f "$tmpfile"
