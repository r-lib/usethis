# use_data_table() Imports data.table

    Code
      roxygen_ns_show()
    Output
      [1] "#' @importFrom data.table .BY"       
      [2] "#' @importFrom data.table .EACHI"    
      [3] "#' @importFrom data.table .GRP"      
      [4] "#' @importFrom data.table .I"        
      [5] "#' @importFrom data.table .N"        
      [6] "#' @importFrom data.table .NGRP"     
      [7] "#' @importFrom data.table .SD"       
      [8] "#' @importFrom data.table :="        
      [9] "#' @importFrom data.table data.table"

# use_data_table() blocks use of Depends

    Code
      use_data_table()
    Message
      ! data.table should be in 'Imports' or 'Suggests', not 'Depends'!
      v Removing data.table from 'Depends'.
      v Adding data.table to 'Imports' field in DESCRIPTION.
      v Adding "@importFrom data.table data.table", "@importFrom data.table :=",
        "@importFrom data.table .SD", "@importFrom data.table .BY", "@importFrom
        data.table .N", "@importFrom data.table .I", "@importFrom data.table .GRP",
        "@importFrom data.table .NGRP", and "@importFrom data.table .EACHI" to
        'R/{TESTPKG}-package.R'.

---

    Code
      roxygen_ns_show()
    Output
      [1] "#' @importFrom data.table .BY"       
      [2] "#' @importFrom data.table .EACHI"    
      [3] "#' @importFrom data.table .GRP"      
      [4] "#' @importFrom data.table .I"        
      [5] "#' @importFrom data.table .N"        
      [6] "#' @importFrom data.table .NGRP"     
      [7] "#' @importFrom data.table .SD"       
      [8] "#' @importFrom data.table :="        
      [9] "#' @importFrom data.table data.table"

