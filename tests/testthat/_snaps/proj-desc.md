# proj_desc_field_append() only messages when adding

    Code
      proj_desc_field_update("Config/Needs/foofy", "alfa", append = TRUE)
    Message
      v Adding 'alfa' to Config/Needs/foofy
    Code
      proj_desc_field_update("Config/Needs/foofy", "alfa", append = TRUE)
      proj_desc_field_update("Config/Needs/foofy", "bravo", append = TRUE)
    Message
      v Adding 'bravo' to Config/Needs/foofy

