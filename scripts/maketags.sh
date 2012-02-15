#!/bin/bash
[ -f scripts/$(basename $0) ] || (echo "Run from project top directory"; exit 1)
ctags -R --totals=yes src/app src/lib cli/
