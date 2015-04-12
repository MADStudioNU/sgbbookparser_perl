# sgbbookparser_perl
Basic Perl Parser of Stanford Graph Base Book Files into Edge and Node CSV files suitable for Gephi

This script takes a Stanford Graph Base "book" data file and converts the data file into two comma-separated-value files suitable for use with the Gephi network graphing program.

This perl script does not do very much error detection, it rather assumes the data file is valid.
For more strict error detection, use the java version of the parser

## usage
./sgbbook2csv.pl PATH_TO_SGB_FILE.dat PATH_TO_NODE_CSV_OUTPUT.csv PATH_TO_EDGE_CSV_OUTPUT.csv
