*! version 1.0.0 YourName DD-Mon-YYYY
*! Program to display a report of missing values for all variables.

program define misschk

    version 14 // For compatibility
    syntax [varlist] // Allow user to specify a subset of variables

    // If user provides no variables, default to all of them
    if `"`varlist'"' == "" {
        unab varlist : _all
    }

    // --- Print the Header ---
    // %-25s reserves 25 characters, left-aligned (-) for a string (s)
    // %12s reserves 12 characters for a string
    display as text %-25s "Variable Name" %12s "N Missing" %12s "% Missing"
    display as text "-------------------------" "   " "-----------" "   " "-----------"

    // --- Loop Through Each Variable ---
    foreach var of local varlist {
        
        // Use 'count' to get the total number of observations
        count
        local total_obs = r(N)

        // Count how many observations are missing for the current variable
        count if missing(`var')
        local n_missing = r(N)
        
        // Calculate the percentage of missing values
        // We add 'float()' to ensure the division is not integer-only
        if `total_obs' > 0 {
            local pct_missing = (`n_missing' / float(`total_obs')) * 100
        }
        else {
            local pct_missing = 0
        }

        // --- Display the Formatted Row ---
        // %-25s: Variable name, 25 characters, left-aligned
        // %12.0f: N Missing, 12 characters, formatted as a number (f) with 0 decimal places
        // %12.2f: % Missing, 12 characters, formatted as a number with 2 decimal places
        display as text %-25s "`var'" as result %12.0f `n_missing' %12.2f `pct_missing'
    }

end
