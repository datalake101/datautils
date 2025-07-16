capture program drop varls

program define varls
    version 16
    
    qui {
        foreach var of varlist _all {
            local vartype : type `var'
            
            if strpos("`vartype'", "str") > 0 {
                levelsof `var', local(levels)
                local num_levels = wordcount(`"`levels'"')
                
                if `num_levels' < 12 & `num_levels' > 0 {
                    noisily di _n as txt "`var' (String)"
                    noisily tabulate `var'
                }
            }
            else {
                levelsof `var', local(levels)
                local num_levels = wordcount("`levels'")
                
                if `num_levels' < 12 & `num_levels' > 0 {
                    local vallab : value label `var'
                    if "`vallab'" != "" {
                        noisily di _n as txt "`var' (Numeric, with value labels)"
                        noisily label list `vallab'
                    }
                    else {
                        noisily di _n as txt "`var' (Numeric, no value labels)"
                        noisily tabulate `var', nolabel
                    }
                }
            }
        }
    }
end
