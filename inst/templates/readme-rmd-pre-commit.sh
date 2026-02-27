#!/bin/bash
README=($(git diff --cached --name-only | grep -Ei '^README\.[qR]?md$'))
MSG="use 'git commit --no-verify' to override this check"

if [[ ${#README[@]} == 0 ]]; then
  exit 0
fi

if [[ README.Rmd -nt README.md ]] || [[ README.qmd -nt README.md ]]; then
  echo -e "README.md is out of date; please re-render README.Rmd/README.qmd\n$MSG"
  exit 1
elif [[ ${#README[@]} -lt 2 ]]; then
  echo -e "README.Rmd/README.qmd and README.md should be both staged\n$MSG"
  exit 1
fi
