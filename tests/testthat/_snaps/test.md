# check_edition() validates inputs

    Code
      check_edition(20)
    Condition
      Error in `check_edition()`:
      x `edition` (20) not available in installed verion of testthat (3.2.0).

---

    Code
      check_edition("x")
    Condition
      Error in `check_edition()`:
      x `edition` must be a single number.

