#!/bin/bash

# ================================================================================
# Script Name: processor.sh
# Author: [Juvenal Carvalho]
# Create Date: [26-04-2025]
# Version: 1.0
# Description: This script downloads a CSV file from a given URL, searches for a term,
#              and formats the output as JSON or CSV. It includes error handling and logging.
# Usage: ./processor.sh <csv_url> <search_term> [output_format: json|csv]
# ================================================================================

S_TIMESTAMP=$(date "+%Y%m%d%H%M%S")
M_TIMESTAMP=$(date "+%Y%m%d%H%M")

# ================================================================================
# CSV Processor Script
# Downloads a CSV file, searches for a term, and formats output (JSON/CSV).
# ================================================================================

# Load configuration and functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../src/utils.sh"
source "${SCRIPT_DIR}/../src/download.sh"
source "${SCRIPT_DIR}/../src/search.sh"
source "${SCRIPT_DIR}/../src/print_csv_files.sh"

# Set log file
LOG_DIR="${SCRIPT_DIR}/../logs"
setup_logging "${LOG_DIR}"

# ================================================================================
# Show usage help
# ================================================================================

usage() {
    echo "Usage: $0 <csv_url> <search_term> [output_format: json|csv]"
    echo "Example: $0 'https://example.com/data.csv' 'Germany' csv"
    exit 1
}

# ================================================================================
# parse_args Function
# ================================================================================
# This function checks the number of arguments, validates the URL format,
# checks if the search term is non-empty, and validates the output format.
# Arguments:
#   $1: CSV URL
#   $2: Search term
#   $3: Output format (optional, default is JSON)
# Returns:
#   0: Success
#   1: Failure
# ================================================================================
parse_args() {
    if [[ $# -lt 2 || $# -gt 3 ]]; then
        echo "[ERROR] Invalid number of arguments."
        usage
    fi

    CSV_URL="$1"
    SEARCH_TERM="$2"
    OUTPUT_FORMAT="${3:-json}" # Default is JSON

    # Validate URL
    if ! is_valid_url "$CSV_URL"; then
        echo "[ERROR] Invalid URL format: '$CSV_URL'"
        usage
    fi

    # Validate search term (non-empty)
    if ! validate_input "$SEARCH_TERM"; then
        echo "[ERROR] Search term must not be empty."
        usage
    fi

    # Validate output format
    if [[ "$OUTPUT_FORMAT" != "json" && "$OUTPUT_FORMAT" != "csv" ]]; then
        echo "[ERROR] Output format must be either 'json' or 'csv'."
        usage
    fi
}

# ================================================================================
# prepare_directories Function
# ================================================================================
# Function: Prepare directories and files.
# This function creates the necessary directories and files for the script to run.
# It checks if the directories exist, creates them if they don't, and backs up existing files.
# It also creates a new data file for the downloaded CSV.
# Arguments:
#   $1: Directory for downloaded files
#   $2: Directory for backup data
#   $3: Path to the downloaded file
# Returns:
#   0: Success
#   1: Failure
#
# ================================================================================
prepare_directories() {

    local downloaded_file_dir="$1"
    local backup_data_dir="$2"
    local downloaded_file="$3"

    dir_create_if_not_exist "${downloaded_file_dir}" || {
        log_error "Failed to create data directory: '${downloaded_file_dir}'"
        exit 1
    }

    # Check if the backup directory exists and is a directory
    dir_create_if_not_exist "${backup_data_dir}" || {
        log_error "Failed to create backup directory: '${backup_data_dir}'"
        exit 1
    }

    # Check if the data directory is empty
    if ! is_directory_empty "${downloaded_file_dir}"; then
        log_info "Cleaning up temporary directory: '${downloaded_file_dir}'"

        backup_data_dir "${backup_data_dir}/${M_TIMESTAMP}" "${downloaded_file_dir}" || {
            log_error "Failed to backup temporary directory: '${downloaded_file_dir}'"
            exit 1
        }

        log_info "${downloaded_file_dir} backed up to: '${backup_data_dir}'"
    fi

    log_info "Creating new data file: '${downloaded_file}'"
    create_file "${downloaded_file}" || {
        log_error "Failed to create new data file: '${downloaded_file}'"
        exit 1
    }

}

# ================================================================================
# Main Function
# ================================================================================
main() {

    log_info "======================================================================"
    log_info "INITIALIZING CSV PROCESSOR SCRIPT"

    log_info "======================================================================"
    log_info "Parsing arguments"
    log_info "======================================================================"

    parse_args "$@"

    log_info "Arguments parsed successfully"

    # Initialize variables
    local data_dir="../data"
    local downloaded_file="${data_dir}/source/source.csv"
    local downloaded_file_dir
    downloaded_file_dir="$(dirname "${downloaded_file}")"

    # Replace spaces in search term with underscores
    local rearch_expr_remove_spaces
    rearch_expr_remove_spaces="$(replace_characters_sed "${SEARCH_TERM}" " " "_")"

    # Create a sanitized output file name
    # Remove spacees in search term and cooncatenate with timestamp
    # shellcheck disable=SC2027
    local search_results="${data_dir}/precessed/results_"${rearch_expr_remove_spaces}"_"${S_TIMESTAMP}".csv"
    local backup_data_dir="${data_dir}/bacuckup"

    log_info "======================================================================"
    log_info "Preparing directories and files"
    log_info "======================================================================"

    prepare_directories "${downloaded_file_dir}" "${backup_data_dir}" "${downloaded_file}" || {
        log_error "Failed to prepare directories"
        exit 1
    }

    log_info "Directories prepared successfully"

    log_info "======================================================================"
    log_info "Starting download from: '${CSV_URL}'"
    log_info "======================================================================"

    download "${CSV_URL}" "${downloaded_file}" || {
        log_error "Download failed"
        exit 1
    }
    log_info "Download completed successfully"

    log_info "======================================================================"
    log_info "Serching for '${SEARCH_TERM}' in CSV: '${downloaded_file}'"
    log_info "======================================================================"

    search_in_csv "$downloaded_file" "$SEARCH_TERM" "$search_results" || {
        log_error "Search failed"
        exit 1
    }

    log_info "Search completed successfully"

    log_info "======================================================================"
    log_info "Printing search result in table fomat"
    log_info "======================================================================"

    if ! path_exists "${search_results}" || ! is_file "${search_results}" || is_empty_file "${search_results}"; then
        log_error "Search results not found or empty"
    else
        print_csv_table "$search_results" || {
            log_error "Failed to print CSV files"
        }
        log_info "Search results printed successfully"
    fi

    log_info "Processing completed successfully"
    log_info "======================================================================"
    log_info "CSV PROCESSOR SCRIPT FINISHED!"
    log_info "======================================================================"
}

# ================================================================================
# Execute if run directly
# ================================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
