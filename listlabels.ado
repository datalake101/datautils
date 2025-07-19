capture program drop listlabels
program define listlabels
    syntax [varlist(default=none)]
    if "`varlist'" == "" {
        quietly describe, short
        local varlist "`r(varlist)'"
    }
    foreach var of varlist `varlist' {
        local label : variable label `var'
        display %-32s "`var'" %-32s `"`label'"'
    }
end
