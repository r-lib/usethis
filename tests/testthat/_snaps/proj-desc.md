# proj_desc_field_append() only messages when adding

    Code
      proj_desc_field_append("Config/Needs/foofy", "alfa")
    Message
      v Adding 'alfa' to Config/Needs/foofy
    Code
      proj_desc_field_append("Config/Needs/foofy", "alfa")
      proj_desc_field_append("Config/Needs/foofy", "bravo")
    Message
      v Adding 'bravo' to Config/Needs/foofy

