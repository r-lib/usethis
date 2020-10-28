# this is not a manual test per se, but can help me find repos with specific
# properties when I need to test against GHE
# e.g. repos I have access to but do not own

library(tidyverse)

Sys.setenv(GITHUB_API_URL = "https://github.ubc.ca")

x <- gh::gh("GET /user/repos", .limit = 100)
length(x)
dat <- tibble(payload = x)
dat %>%
  hoist(payload, "full_name") %>%
  print(n = Inf)

create_from_github("github-administration/migration", destdir = "~/tmp")

create_from_github(
  "https://github.ubc.ca/github-administration/migration",
  destdir = "~/tmp",
  fork = FALSE
)
