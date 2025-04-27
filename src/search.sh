#!/bin/bash

# ================================================================================
# Script Name: utils.sh
# Description: Utility functions for logging and file/directory management.
# Author: [Juvenal Carvalho]
# Update Date: [23-04-2025]
# ================================================================================

# This script provides a function to search for a term in a CSV file and extract matching rows.
# It uses awk for efficient searching and supports quoted fields. The script also includes logging functionality
# for better traceability.

# ================================================================================
# Include the helper functions
# ================================================================================
# This line determines the absolute path of the directory containing the script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/remove_whitespace.sh"

# ================================================================================
# Function: search_in_csv
# Description: Searches for a term in a CSV file and extracts matching rows.
# Arguments:
#   $1: Input CSV file
#   $2: Search term (regex)
#   $3: Output CSV file
# Returns:
#   0: Success
#   1: Failure
# Usage:
#   search_in_csv <input_file> <search_terms> <output_file>
# ================================================================================
search_in_csv() {
    local input_file="$1"
    local search_terms="$2"
    local output_file="$3"

    log_info "Searching for '${search_terms}' in CSV: '${input_file}'"

    # Validate inputs
    if ! validate_input "${input_file}" || ! validate_input "${search_terms}" || ! validate_input "${output_file}"; then
        usage
        log_error "Invalid arguments. Please provide valid input, search terms, and output file."
        return 1
    fi

    if ! path_exists "${input_file}" || ! is_file "${input_file}" || is_empty_file "${input_file}"; then
        log_error "Input file '${input_file}' not found or empty."
        return 1
    fi

    local output_dir
    output_dir="$(dirname "${output_file}")"

    dir_create_if_not_exist "${output_dir}" || {
        log_error "Failed to create output directory: '${output_dir}'"
        return 1
    }

    file_create_if_not_exist "${output_file}" || {
        log_error "Issue accessing output file: '${output_file}'"
        return 1
    }

    # Write header first
    head -n 1 "${input_file}" >"${output_file}"

    if command -v rg >/dev/null 2>&1; then
        log_info "Using ripgrep (rg) for high-performance search"

        tail -n +2 "${input_file}" | rg --no-heading --ignore-case --fixed-strings "${search_terms}" >>"${output_file}"

    else
        log_warning "ripgrep (rg) not found. Falling back to awk search (may be slower)."

        awk -F',' -v term="${search_terms}" '
                BEGIN { IGNORECASE = 1 }
                NR == 1 { next }
                {
                    gsub(/^"|"$/, "", $1);  # remove quotes
                    if ($1 ~ term) {
                        print $0
                    }
                }
        ' "${input_file}" >>"${output_file}"

    fi

    # Final check if any matches found
    local line_count
    line_count=$(wc -l <"${output_file}")

    if [[ "${line_count}" -le 1 ]]; then
        log_warning "No matches found for '${search_terms}' in '${input_file}'."
        rm -f "${output_file}"
        return 0
    fi

    log_info "Search completed. Results saved to '${output_file}'"
    return 0
}

# Create usage function
usage() {
    echo "Usage: $0 --input <input_file> --search <search_terms> --output <output_file>"
    echo "  -i, --input   Path to the input CSV file"
    echo "  -s, --search  Search terms (regex) to match in the CSV"
    echo "  -o, --output  Path to the output CSV file"
}

# ================================================================================
# parse_args Function
# ================================================================================
# Function: Parse command-line arguments
# This function processes command-line arguments and sets the corresponding variables.
# It uses getopts to handle options and validates the inputs.
# It checks if the required arguments are provided and if they are valid.
# If any required arguments are missing or invalid, it prints an error message and usage information.
# Arguments:
#   $1: Command-line arguments
# Returns:
#   0: Success
#   1: Failure
# ================================================================================
parse_args() {
    while getopts ":i:s:o:" opt; do
        case "${opt}" in
        i)
            INPUT_FILE="${OPTARG}"
            ;;
        s)
            SEARCH_TERMS="${OPTARG}"
            ;;
        o)
            OUTPUT_FILE="${OPTARG}"
            ;;
        *)
            log_error "[ERROR] Invalid option: -${OPTARG}" >&2
            usage
            exit 1
            ;;
        esac
    done

    # Validate required arguments
    if ! validate_input "${INPUT_FILE}" || ! validate_input "${SEARCH_TERMS}" || ! validate_input "${OUTPUT_FILE}"; then
        usage
        log_error "Usage: $0 --input <input_file> --search <search_terms> --output <output_file>"
        exit 1
    fi
}

main() {
    # Example usage
    # Call usage function if no arguments are provided
    if [[ $# -eq 0 ]]; then
        usage
    fi
    # Print script information

    log_info "======================================================================"
    log_info "Parsing arguments"
    log_info "======================================================================"

    parse_args "$@"

    local trim_space_search_term
    trim_space_search_term="$(replace_characters_sed "${SEARCH_TERMS}" " " "_")"
    local output_file
    output_file="${OUTPUT_FILE}_$(echo "${trim_space_search_term}" | tr '[:upper:]' '[:lower:]').csv"

    #local output_file="${OUTPUT_FILE}_${trim_space_search_term}.csv"
    search_in_csv "${INPUT_FILE}" "${SEARCH_TERMS}" "${output_file}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
