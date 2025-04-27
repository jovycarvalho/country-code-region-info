#!/usr/bin/env bash
# ================================================================================
# Script Name: print_csv_files.sh
# Author: [Juvenal Carvalho]
# Create Date: [26-04-2025]
# Version: 1.0
# Description: This script provides a function to print the contents of a CSV file
#              as a formatted table. It uses awk for processing and supports custom delimiters.
#              The script also includes error handling and logging functionality.
#
# Usage: ./print_csv_files.sh <csv_file> [delimiter]
# ================================================================================
# ================================================================================
# Include the helper functions
# ================================================================================
# This line determines the absolute path of the directory containing the script.
# This is useful for ensuring that the script can find its dependencies and resources.
# The `dirname` command extracts the directory name from the script's path, and `pwd`
# gives the absolute path.
# The `BASH_SOURCE` variable contains the path of the script being executed, and
#`${BASH_SOURCE[0]}` refers to the current script.
# =================================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ================================================================================
# Function: Print CSV file contents as a formatted table
# ================================================================================
print_csv_table() {
    local csv_file="$1"
    local delimiter="${2:-,}" # Default delimiter is ','

    # Validate input
    if ! validate_input "${csv_file}"; then
        log_error "No CSV file specified."
        return 1
    fi

    if ! path_exists "${csv_file}" || ! is_file "${csv_file}" || is_empty_file "${csv_file}"; then
        log_error "'${csv_file}' not found or empty"
        return 1
    fi

    if [[ ! -r "${csv_file}" ]]; then
        log_error "File is not readable: ${csv_file}"
        return 1
    fi

    # Process CSV using awk to calculate max width per column first
    awk -v DELIM="${delimiter}" '
    BEGIN {
        FS = DELIM;
    }
    {
        for (i = 1; i <= NF; i++) {
            field = $i;
            gsub(/^"|"$/, "", field); # Remove surrounding quotes if present
            gsub(/\r/, "", field);     # Remove carriage returns (Windows files)
            if (length(field) > max_len[i]) {
                max_len[i] = length(field);
            }
            data[NR, i] = field;
        }
        if (NF > max_fields) {
            max_fields = NF;
        }
        total_rows = NR;
    }
    END {
        # Print table header
        for (i = 1; i <= max_fields; i++) {
            printf "%-*s ", max_len[i]+2, toupper(data[1, i]);
        }
        print "";
        for (i = 1; i <= max_fields; i++) {
            for (j = 0; j < max_len[i]+2; j++) {
                printf "-";
            }
            printf " ";
        }
        print "";

        # Print table data
        for (row = 2; row <= total_rows; row++) {
            for (col = 1; col <= max_fields; col++) {
                printf "%-*s ", max_len[col]+2, data[row, col];
            }
            print "";
        }
    }
    ' "${csv_file}"
}

# define a usage function to display help
usage() {
    echo "Usage: $0 -f <csv_file> [-d <delimiter>]"
    echo "  -f <csv_file>   Specify the CSV file to be processed (required)"
    echo "  -d <delimiter>  Specify the delimiter used in the CSV file (optional, default is ',')"
    exit 1
}

# ================================================================================
# Function: Parse command-line arguments
# ================================================================================
# This function uses getopts to parse command-line options.
# It supports the following options:
# -f: Specify the CSV file to be processed (required)
# -d: Specify the delimiter used in the CSV file (optional, default is ',')
# It validates the provided arguments and sets default values where necessary.
# If the required arguments are not provided or invalid, it prints an error message
# and usage information.
# ================================================================================
parse_args() {
    while getopts ":f:d:" opt; do
        case "${opt}" in
        f)
            CSV_FILE="${OPTARG}"
            ;;
        d)
            DELIMITER="${OPTARG}"
            ;;
        *)
            log_error "[ERROR] Invalid option: -${OPTARG}" >&2
            usage
            exit 1
            ;;
        esac
    done

    # Validate required arguments
    if ! path_exists "${CSV_FILE}" || ! is_file "${CSV_FILE}" || is_empty_file "${CSV_FILE}"; then
        log_error "'${CSV_FILE}' not found or empty"
        usage
        exit 1
    fi

    # Validate delimiter
    if ! validate_input "${DELIMITER}"; then
        log_error " Delimiter not specified, using default ','"
        DELIMITER=","
    fi

}

# ================================================================================
# Main function to handle script execution
# ================================================================================
main() {

    # Call usage function if no arguments are provided
    if [[ $# -eq 0 ]]; then
        usage
    fi
    # Print script information

    log_info "======================================================================"
    log_info "Parsing arguments"
    log_info "======================================================================"

    parse_args "$@"

    print_csv_table "$CSV_FILE" "$DELIMITER"
}
# ================================================================================
# Check if the script is being run directly
# ================================================================================
# This check ensures that the script can be sourced without executing the main function.
# If the script is run directly, it will execute the main function.
# If the script is sourced, the main function will not be executed.
# This is useful for modular scripts that can be reused in other scripts or contexts.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
