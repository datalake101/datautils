* varlabvals.ado
program define vsm
    version 16
    syntax [varlist(default=all)]
    
    display as text "{hline 90}"
    display as text %-14s "Variable" " | " %-28s "Label" " | " "Values"
    display as text "{hline 90}"
    
    foreach var of local varlist {
        * Handle variable name (truncate >14 chars)
        local name = cond(length("`var'")>14, substr("`var'",1,11) + "...", "`var'")
        
        * Get variable label (handle missing/truncate >28 chars)
        local varlab : variable label `var'
        if `"`varlab'"' == "" local varlab " "
        if length(`"`varlab'"') > 28 local varlab = substr(`"`varlab'"',1,25) + "..."
        
        * Get unique values (truncate >42 chars)
        capture levelsof `var' if !missing(`var'), local(vals) clean separate(", ")
        if _rc local vals "N/A (error)"
        else if length(`"`vals'"') > 42 local vals = substr(`"`vals'"',1,39) + "..."
        
        * Display formatted row
        display as result %-14s "`name'" " | " %-28s `"`varlab'"' " | " `"`vals'"'
    }
    
    display as text "{hline 90}"
end
