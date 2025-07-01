*! version 9.0.0 FINAL YourName DD-Mon-YYYY
*! Program to describe variable categories. Fixes r(198) error by
*! correcting code formatting on an 'if' statement's open brace.

program define varcats

    version 14 // Keep for compatibility

    // --- FULLY MANUAL PARSING OF VARLIST AND OPTIONS ---
    local raw_input `"`0'"'
    local comma_pos = strpos(`"`raw_input'"', ",")
    if `comma_pos' > 0 {
        local varlist = trim(substr(`"`raw_input'"', 1, `comma_pos'-1))
        local options = trim(substr(`"`raw_input'"', `comma_pos', .))
    }
    else {
        local varlist `"`raw_input'"'
        local options ""
    }

    local export_filename ""
    if `"`options'"' != "" {
        gettoken keyword rest : options, parse("()")
        gettoken filename rest : rest, parse("()")
        if `"`keyword'"' == "export" | `"`keyword'"' == ",export" {
            local export_filename `"`filename'"'
        }
    }
    
    if `"`varlist'"' == "" {
        unab varlist : _all
    }


    // --- SETUP FOR WORD EXPORT (if requested) ---
    if `"`export_filename'"' != "" {
        if !strmatch(`"`export_filename'"', "*.docx") {
            local export_filename `"`export_filename'.docx"'
        }
        putdocx begin, replace
        putdocx paragraph, style(Title)
        putdocx text ("Variable Category Description")
        putdocx paragraph
        putdocx table doctable = (2), border(all)
        putdocx table doctable(1,1), bold = on
        putdocx table doctable(1,1) = ("Variable Name")
        putdocx table doctable(1,2), bold = on
        putdocx table doctable(1,2) = ("Categories / Description")
        local row_num = 2
    }


    // --- MAIN PROGRAM LOGIC ---
    
    local continuous_threshold = 10
    display as text %-20s "Variable Name" "   " as result "Categories / Description"
    display as text %-20s "---------------" "   " as result "------------------------"

    foreach var of local varlist {
        local varname_display `"`var'"'
        local printed_something = 0
        local vallabel : value label `var'

        // --- Streamlined Logic: Determine category text once, then display/export ---
        
        if `"`vallabel'"' != "" { // Case 1: Value Labels
            quietly levelsof `var', local(levels) missing
            foreach level of local levels {
                local lbl : label (`var') `level'
                local category_text `"`level': `lbl'"'
                display as text %-20s `"`varname_display'"' "   " as result `"`category_text'"'
                if `"`export_filename'"' != "" {
                    putdocx table doctable(`row_num', 1) = (`"`varname_display'"')
                    putdocx table doctable(`row_num', 2) = (`"`category_text'"')
                    local ++row_num
                }
                local varname_display ""
            }
            local printed_something = 1
        }
        else {
            local vartype : type `var'
            if substr(`"`vartype'"', 1, 3) == "str" { // Case 2: String Variable
                qui levelsof `var', local(levels)
                if wordcount(`"`levels'"') > `continuous_threshold' {
                    local category_text "String (many unique values)"
                    display as text %-20s `"`varname_display'"' "   " as result `"`category_text'"'
                    if `"`export_filename'"' != "" {
                        putdocx table doctable(`row_num', 1) = (`"`varname_display'"')
                        putdocx table doctable(`row_num', 2) = (`"`category_text'"')
                        local ++row_num
                    }
                }
                else {
                    foreach level of local levels {
                        local category_text `"`level'"'
                        display as text %-20s `"`varname_display'"' "   " as result `"`category_text'"'
                        if `"`export_filename'"' != "" {
                            putdocx table doctable(`row_num', 1) = (`"`varname_display'"')
                            putdocx table doctable(`row_num', 2) = (`"`category_text'"')
                            local ++row_num
                        }
                        local varname_display ""
                    }
                }
                local printed_something = 1
            }
            else { // Case 3: Numeric Variable
                qui inspect `var'
                if (r(N_unique) > `continuous_threshold' | r(N_int) < r(N)) {
                    qui su `var', meanonly
                    // --- ** THIS IS THE CORRECTED CODE ** ---
                    if r(N) > 0 {
                        local category_text "Mean = " + string(r(mean), "%9.2f")
                    }
                    else { 
                        local category_text "(All missing)" 
                    }
                    // ------------------------------------------
                    display as text %-20s `"`varname_display'"' "   " as result `"`category_text'"'
                    if `"`export_filename'"' != "" {
                        putdocx table doctable(`row_num', 1) = (`"`varname_display'"')
                        putdocx table doctable(`row_num', 2) = (`"`category_text'"')
                        local ++row_num
                    }
                }
                else {
                    levelsof `var', local(levels) missing
                    foreach level of local levels {
                        local category_text "`level'"
                        display as text %-20s `"`varname_display'"' "   " as result `"`category_text'"'
                        if `"`export_filename'"' != "" {
                            putdocx table doctable(`row_num', 1) = (`"`varname_display'"')
                            putdocx table doctable(`row_num', 2) = (`"`category_text'"')
                            local ++row_num
                        }
                        local varname_display ""
                    }
                }
                local printed_something = 1
            }
        }
        if `printed_something' == 0 {
            display as text %-20s `"`varname_display'"' "   " as result "(All missing or empty)"
        }
    }

    // --- SAVE THE WORD DOCUMENT (if requested) ---
    if `"`export_filename'"' != "" {
        putdocx save `"`export_filename'"', replace
        display as text _n "Success! Output saved to: " as result `"`export_filename'"'
    }
end
