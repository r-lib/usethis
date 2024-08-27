# we message for new type and are silent for same type

    Code
      use_dependency("crayon", "Imports")
    Message
      v Adding crayon to 'Imports' field in DESCRIPTION.

# we message for version change and are silent for same version

    Code
      use_dependency("crayon", "Imports")
    Message
      v Adding crayon to 'Imports' field in DESCRIPTION.

---

    Code
      use_dependency("crayon", "Imports", min_version = "1.0.0")
    Message
      v Increasing crayon version to ">= 1.0.0" in DESCRIPTION.

---

    Code
      use_dependency("crayon", "Imports", min_version = "2.0.0")
    Message
      v Increasing crayon version to ">= 2.0.0" in DESCRIPTION.

---

    Code
      use_dependency("crayon", "Imports", min_version = "1.0.0")
    Message
      v Decreasing crayon version to ">= 1.0.0" in DESCRIPTION.

# use_dependency() upgrades a dependency

    Code
      use_dependency("usethis", "Suggests")
    Message
      v Adding usethis to 'Suggests' field in DESCRIPTION.

---

    Code
      use_dependency("usethis", "Imports")
    Message
      v Moving usethis from 'Suggests' to 'Imports' field in DESCRIPTION.

# use_dependency() declines to downgrade a dependency

    Code
      use_dependency("usethis", "Imports")
    Message
      v Adding usethis to 'Imports' field in DESCRIPTION.

---

    Code
      use_dependency("usethis", "Suggests")
    Message
      ! Package usethis is already listed in 'Imports' in DESCRIPTION; no change
        made.

# can add LinkingTo dependency if other dependency already exists

    Code
      use_dependency("rlang", "LinkingTo")
    Message
      v Adding rlang to 'LinkingTo' field in DESCRIPTION.

# use_dependency() does not fall over on 2nd LinkingTo request

    Code
      use_dependency("rlang", "LinkingTo")

# use_dependency() can level up a LinkingTo dependency

    Code
      use_package("rlang")
    Message
      v Moving rlang from 'Suggests' to 'Imports' field in DESCRIPTION.
      [ ] Refer to functions with `rlang::fun()`.

