*! varcats: display variable names and categories for numeric variables
*! version 2.5.0 - Fixed row addition issues
program define varcatsss
    version 15
    syntax [varlist(default=none)] [using/] [, APPend REPLACE]
    

    // If no varlist specified, use all numeric variables
    if "`varlist'" == "" {
        quietly ds, has(type numeric)
        local varlist `r(varlist)'
    }
    else {
        // Keep only numeric variables from the user-specified varlist
        quietly ds `varlist', has(type numeric)
        local varlist `r(varlist)'
    }
    
    // Exit if no numeric variables
    if "`varlist'" == "" {
        display as text "No numeric variables found."
        exit
    }
    
    // Setup Word document if using option is specified
    if `"`using'"' != "" {
        // Clear any active putdocx document
        capture putdocx close
        capture putdocx clear
        
        // Handle document creation
        if "`append'" != "" {
            putdocx append `"`using'"'
        }
        else if "`replace'" != "" {
            putdocx begin
        }
        else {
            capture confirm file `"`using'"'
            if _rc {
                putdocx begin
            }
            else {
                display as error "File `using' already exists. Use replace or append option."
                exit 602
            }
        }
        
        // Create document header
        putdocx paragraph, style("Heading1")
        putdocx text ("Variable Categories Report")
        putdocx paragraph
        putdocx text ("Generated on: $S_DATE at $S_TIME")
        putdocx table tbl = (1,2), border(all, single) layout(autofitcontents)
        putdocx table tbl(1,1) = ("Variable Name"), halign(center) bold
        putdocx table tbl(1,2) = ("Categories"), halign(center) bold
        local row = 1  // Start after header row
    }
    
    // Find max variable name length for alignment
    local maxlen = 0
    foreach v of local varlist {
        if length("`v'") > `maxlen' {
            local maxlen = length("`v'")
        }
    }
    local col1 = `maxlen' + 3  // First column width
    
    // Display header
    display _newline
    display as text %`maxlen's "Variable Name" _col(`col1') "categories"
    display ""
    
    // Process each variable
    foreach v of local varlist {
        local vallab : value label `v'  // Attached value label
        
        // Get distinct values including missing
        capture levelsof `v', local(values) missing
        if _rc {
            // Results window output
            display %`maxlen's "`v'" _col(`col1') "Error: cannot get levels"
            
            // Word document output
            if `"`using'"' != "" {
                local ++row
                putdocx table tbl = (1,2), tabletype(addrow) rownum(`row')
                putdocx table tbl(`row',1) = ("`v'"), bold
                putdocx table tbl(`row',2) = ("Error: cannot get levels")
            }
            continue
        }
        
        if "`vallab'" != "" {
            // Has value labels (categorical)
            if "`values'" == "" {
                // Results window output
                display %`maxlen's "`v'" _col(`col1') "No observations"
                
                // Word document output
                if `"`using'"' != "" {
                    local ++row
                    putdocx table tbl = (1,2), tabletype(addrow) rownum(`row')
                    putdocx table tbl(`row',1) = ("`v'"), bold
                    putdocx table tbl(`row',2) = ("No observations")
                }
            }
            else {
                local first 1
                local valcount 0
                foreach val in `values' {
                    local valcount = `valcount' + 1
                    capture local lab : label `vallab' `val'
                    if _rc local lab `val'  // Fallback to raw value
                    
                    // Results window output
                    if `first' {
                        display %`maxlen's "`v'" _col(`col1') "`val' `lab'"
                        local first 0
                    }
                    else {
                        display %`maxlen's "" _col(`col1') "`val' `lab'"
                    }
                    
                    // Word document output
                    if `"`using'"' != "" {
                        local ++row
                        putdocx table tbl = (1,2), tabletype(addrow) rownum(`row')
                        if `valcount' == 1 {
                            putdocx table tbl(`row',1) = ("`v'"), bold
                        }
                        else {
                            putdocx table tbl(`row',1) = ("")
                        }
                        putdocx table tbl(`row',2) = ("`val' `lab'")
                    }
                }
            }
        }
        else {
            // No value labels (continuous)
            // Results window output
            display %`maxlen's "`v'" _col(`col1') "Continuous"
            
            // Word document output
            if `"`using'"' != "" {
                local ++row
                putdocx table tbl = (1,2), tabletype(addrow) rownum(`row')
                putdocx table tbl(`row',1) = ("`v'"), bold
                putdocx table tbl(`row',2) = ("Continuous")
            }
        }
    }
    
    // Save Word document if using option is specified
    if `"`using'"' != "" {
        putdocx save `"`using'"', replace
        display _newline
        display as text "Output saved to Word document: " as result `"`using'"'
    }

end
