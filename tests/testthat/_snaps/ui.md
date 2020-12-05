# basic UI actions behave as expected

    Code
      ui_line("line")
    Message <message>
      line
    Code
      ui_todo("to do")
    Message <message>
      * to do
    Code
      ui_done("done")
    Message <message>
      v done
    Code
      ui_oops("oops")
    Message <message>
      x oops
    Code
      ui_info("info")
    Message <message>
      i info
    Code
      ui_code_block(c("x <- 1", "y <- 2"))
    Message <message>
        x <- 1
        y <- 2
    Code
      ui_warn("a warning")
    Warning <simpleWarning>
      a warning

