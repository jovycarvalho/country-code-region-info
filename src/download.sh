#!/bin/bash

#
# This script provides a function to download a CSV file from a given URL
# and validate its content. It uses curl or wget for downloading and checks if the
# downloaded file is a valid CSV. The script also includes logging functionality
# for better traceability.

# ================================================================================
# Include the helper functions
# ================================================================================

# This line determines the absolute path of the directory containing the script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# ================================================================================
# Function Definitions

# Downloads a CSV file from a URL with validation
# Arguments:
#   1. URL of the CSV file
#   2. Output path to save the downloaded file
# Returns:
#   0 on success, 1 on failure
# Usage:
#   download_csv <url> <output_path>
# ================================================================================

download() {
    local url="$1"
    local output_path="$2"

    echo "Downloading CSV from URL: ${url}"
    echo "Output path: ${output_path}"

    # Validate inputs
    if ! validate_input "${url}" || ! validate_input "${output_path}"; then
        log_error "Usage: download_csv <url> <output_path>"
        return 1
    fi

    if [[ ! "${url}" =~ ^https?:// ]]; then
        log_error "Invalid URL: '${url}'"
        return 1
    fi

    local output_dir
    output_dir="$(dirname "${output_path}")"

    if ! is_directory "${output_dir}"; then
        log_error "Output  does not exist: '${output_dir}'"
        return 1
    fi

    log_info "Downloading CSV from '${url}' to '${output_path}'"

    # ================================================================================
    # Download using curl or wget
    # ================================================================================
    if command -v curl &>/dev/null; then
        if ! curl -sSLf "${url}" -o "${output_path}"; then
            log_error "Failed to download CSV from '${url}' using curl"
            return 1
        fi
    elif command -v wget &>/dev/null; then
        if ! wget -qO "${output_path}" "${url}"; then
            log_error "Failed to download CSV from '${url}' using wget"
            return 1
        fi
    else
        log_error " [ERROR] Neither curl nor wget is installed"
        return 1
    fi

    # ================================================================================
    # Validate the downloaded file
    # ================================================================================
    if ! path_exists "${output_path}" || ! is_file "${output_path}"; then
        log_error "Downloaded file is invalid or missing: '${output_path}'"
        return 1
    fi

    if [[ "${output_path}" != *.csv ]]; then
        log_warn "Downloaded file does not have a .csv extension: '${output_path}'"
    fi

    if is_empty_file "${output_path}"; then
        log_warn "Downloaded file is empty: '${output_path}'"
    fi

    log_info "CSV downloaded successfully to '${output_path}'"
    return 0
}

# Example usage:
# 1. Download a CSV file from a URL and save it to a specified path
# 2. Validate the downloaded file

main() {
    setup_logging "."
    download "$@"

    if [[ $? -ne 0 ]]; then
        log_error "Failed to download CSV file"
        exit 1
    fi
}

# Equivalent to: if __name__ == "__main__"
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$1" "$2"
fi
