_datautils_: a collection of Stata commands designed to streamline common data exploration and cleaning tasks. 
These utilities provide quick, formatted summaries of your data, helping you to understand variable contents and quality at a glance.

**Installation**
The package is hosted on GitHub and can be installed directly from Stata. Simply run the following command in your Stata console:

net install datautils, from("https://raw.githubusercontent.com/datalake101/datautils/master/")



**Commands Included**
varcats: Intelligently describes the contents of variables. It shows value labels for labeled variables, lists unique categories for categorical variables, and reports continuous or high-cardinality variables with their mean. It also includes an option to export the summary to a formatted Word document.
misschk: Generates a clean, formatted report showing the count and percentage of missing values for each variable in the dataset.
varlabels: Provides a compact, side-by-side list of variable names and their corresponding variable labels for quick reference.
keepcat: A data management utility that keeps only the categorical variables in the dataset, based on a set of rules (value labels, strings, or a low number of unique integers).

Example Usage

Generated stata
// Load an example dataset
sysuse auto, clear

// Describe the contents of specific variables
varcats price foreign rep78

// Check for missing values in all variables
misschk

// Get a quick list of variable labels
varlabels
