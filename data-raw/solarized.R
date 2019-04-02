library(tidyverse)
library(usethis)
library(here)

# extracted from the solarized README
# https://github.com/altercation/solarized
# I couldn't easily find this exact plain text file in the repo
# I made a hand edit to create proper column space between TERMCOL and XTERM/HEX
df <- read_table(here("data-raw", "solarized-raw.txt"), comment = "-")

df <- df %>%
  select(SOLARIZED, HEX, `XTERM/HEX`) %>%
  extract(`XTERM/HEX`, into = "xterm_hex", "(#[0-9a-f]{6})")

write_csv(df, path = here("data-raw", "solarized.csv"))

dput(
  deframe(select(df, SOLARIZED, HEX)),
  file = here("data-raw", "solarized-hex.R")
)
dput(
  deframe(select(df, SOLARIZED, xterm_hex)),
  file = here("data-raw", "solarized-xterm-hex.R")
)
