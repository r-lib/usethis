# check_is_named_list() works

    Code
      user_facing_function(NULL)
    Condition
      Error in `check_is_named_list()`:
      x `somevar` must be a list, not NULL.

---

    Code
      user_facing_function(c(a = "a", b = "b"))
    Condition
      Error in `check_is_named_list()`:
      x `somevar` must be a list, not a character vector.

---

    Code
      user_facing_function(list("a", b = 2))
    Condition
      Error in `check_is_named_list()`:
      x Names of `somevar` must be non-missing, non-empty, and non-duplicated.

