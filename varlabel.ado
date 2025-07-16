 
program define varlabel
    syntax varlist
    
    display _n "Variable Name" _col(25) "Variable Label"
    display "-----------------------" _col(25) "----------------------------------"
    
    foreach var of local varlist {
        local label : var label `var'
        display %-22s "`var'" _col(25) "`label'"
    }
    
end 
