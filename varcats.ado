program define varcatss
    version 13.0
    syntax

    di as text "Variable Name       Categories"
    di as text "--------------------------------------"

    foreach var of varlist _all {
        // Get value label name
        local lblname : value label `var'

        if "`lblname'" != "" {
            // Variable has value labels
            capture levelsof `var', local(levels) clean
            if _rc == 0 {
                di as text "`var'"
                foreach lvl of local levels {
                    capture local lbl : label `lblname' `lvl'
                    if _rc == 0 {
                        di _col(22) "`lvl' `lbl'"
                    }
                    else {
                        di _col(22) "`lvl'"
                    }
                }
            }
            else {
                di as text "`var'" _col(22) "Categorical (label: `lblname')"
            }
        }
        else {
            // No value label: check if constant or continuous
            quietly summarize `var', meanonly
            if r(min) == r(max) {
                di as text "`var'" _col(22) "Constant"
            }
            else {
                di as text "`var'" _col(22) "Continuous"
            }
        }

        // Drop locals to avoid carryover
        macro drop lblname
        macro drop levels
        macro drop lbl
    }
end
