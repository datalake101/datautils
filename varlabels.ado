program define varlabels, rclass

    version 16
    
    display as text %-20s "Variable Name" %-40s "Variable Label"
    display as text %-20s "---------------" %-40s "----------------"

    unab allvars : _all

    foreach var of local allvars {
        local label : var label `var'
        display as text %-20s "`var'" as result %-40s `"`label'"'
    }

end
