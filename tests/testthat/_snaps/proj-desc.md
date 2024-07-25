# proj_desc_field_update() only messages when adding

    Code
      proj_desc_field_update("Config/Needs/foofy", "alfa", append = TRUE)
    Message
      v Adding "alfa" to 'Config/Needs/foofy'.
    Code
      proj_desc_field_update("Config/Needs/foofy", "alfa", append = TRUE)
      proj_desc_field_update("Config/Needs/foofy", "bravo", append = TRUE)
    Message
      v Adding "bravo" to 'Config/Needs/foofy'.

# proj_desc_field_update() works with multiple values

    Code
      proj_desc_field_update("Config/Needs/foofy", c("alfa", "bravo"), append = TRUE)
    Message
      v Adding "alfa" and "bravo" to 'Config/Needs/foofy'.

