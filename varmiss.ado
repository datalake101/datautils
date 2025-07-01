*! varmiss: Display variables sorted by missing percentage (highest first)
*! version 2.1.1
program define varmiss
    version 15
    syntax [varlist(default=all)] [, SAVing(string) REPLACE]
    
    // Get all variables if none specified
    if "`varlist'" == "all" {
        quietly ds
        local varlist `r(varlist)'
    }
    
    // Create result containers
    local var_count : word count `varlist'
    matrix results = J(`var_count', 3, .)
    local vnames ""
    local vtypes ""
    
    // Get total observations
    local total_obs = _N
    
    // Process each variable
    local i = 1
    foreach v of local varlist {
        // Count non-missing values
        quietly count if !missing(`v')
        local n_nonmiss = r(N)
        
        // Calculate missing percentage
        local pct_missing = 100 * (1 - `n_nonmiss'/`total_obs')
        
        // Get variable type
        local vtype : type `v'
        
        // Store results
        matrix results[`i', 1] = `n_nonmiss'
        matrix results[`i', 2] = `pct_missing'
        matrix results[`i', 3] = `i'  // Original position
        
        // Store names and types
        local vnames `vnames' `v'
        local vtypes `vtypes' `vtype'
        
        local i = `i' + 1
    }
    
    // Convert to variables for sorting
    preserve
    clear
    gen str32 Variable = ""
    gen str10 Type = ""
    gen long N = .
    gen double pct_missing = .
    gen byte orig_order = .
    
    set obs `var_count'
    forvalues i = 1/`var_count' {
        replace Variable = word("`vnames'", `i') in `i'
        replace Type = word("`vtypes'", `i') in `i'
        replace N = results[`i', 1] in `i'
        replace pct_missing = results[`i', 2] in `i'
        replace orig_order = results[`i', 3] in `i'
    }
    
    // Sort by missing percentage descending
    gsort -pct_missing
    
    // Format percentage display
    gen str10 pct_display = string(pct_missing, "%5.2f") + "%"
    
    // Display header
    display _n as text _dup(55) "-"
    display as text %-20s "Variable" ///
        _col(22) %-10s "Type" ///
        _col(34) %12s "N (non-missing)" ///
        _col(50) %12s "% Missing"
    display as text _dup(55) "-"
    
    // Display sorted results
    forvalues i = 1/`=_N' {
        local v = Variable[`i']
        local t = Type[`i']
        local n = N[`i']
        local p = pct_display[`i']
        
        display as text %-20s "`v'" ///
            _col(22) %-10s "`t'" ///
            _col(34) %12s "`n'" ///
            _col(50) %12s "`p'"
    }
    display as text _dup(55) "-"
    
    // Save to dataset if requested
    if `"`saving'"' != "" {
        keep Variable Type N pct_missing
        rename pct_missing pct_Missing
        label var Variable "Variable Name"
        label var Type "Variable Type"
        label var N "Non-missing Count"
        label var pct_Missing "Missing Percentage"
        format pct_Missing %5.2f
        
        save `"`saving'"', `replace'
        display _n as text "Results saved to: " as result `"`saving'"'
    }
    else {
        // Restore original data if not saving
        restore
    }
end
