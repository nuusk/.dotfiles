#!/bin/bash

# Take region screenshot, open in Satty for annotation
tmpfile=$(mktemp --suffix .png)
/usr/bin/grim -g "$(slurp)" "$tmpfile" && /usr/bin/satty --floating-hack --filename "$tmpfile"
