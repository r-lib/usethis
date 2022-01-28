# basic UI actions behave as expected

    Code
      ui_line("line")
    Message <rlang_message>
      line
    Code
      ui_todo("to do")
    Message <rlang_message>
      * to do
    Code
      ui_done("done")
    Message <rlang_message>
      v done
    Code
      ui_oops("oops")
    Message <rlang_message>
      x oops
    Code
      ui_info("info")
    Message <rlang_message>
      i info
    Code
      ui_code_block(c("x <- 1", "y <- 2"))
    Message <rlang_message>
        x <- 1
        y <- 2
    Code
      ui_warn("a warning")
    Warning <simpleWarning>
      a warning

