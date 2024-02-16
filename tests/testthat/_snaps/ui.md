# basic legacy UI actions behave as expected

    Code
      ui_line("line")
    Message
      line
    Code
      ui_todo("to do")
    Message
      * to do
    Code
      ui_done("done")
    Message
      v done
    Code
      ui_oops("oops")
    Message
      x oops
    Code
      ui_info("info")
    Message
      i info
    Code
      ui_code_block(c("x <- 1", "y <- 2"))
    Message
        x <- 1
        y <- 2
    Code
      ui_warn("a warning")
    Condition
      Warning:
      a warning

