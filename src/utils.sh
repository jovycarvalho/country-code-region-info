#!/bin/bash

# ================================================================================
# Script Name: utils.sh
# Description: Utility functions for logging and file/directory management.
# Author: [Juvenal Carvalho]
# Create Date: [17-10-2024]
# Update Date: [23-04-2025]
# ================================================================================
# This script provides utility functions for logging, file and directory management,
# and input validation. It includes functions to set up logging, log messages at different
# levels, check if paths exist, create files and directories, and clean directories.
# It is designed to be sourced by other scripts to provide common functionality.
# ================================================================================

# Check if the script is being sourced
# This prevents the script from being executed if it is run directly.
# It ensures that the functions defined in this script are only available when sourced.
# This is a common practice in shell scripting to avoid unintended execution.
# ================================================================================

S_TIMESTAMP=$(date "+%Y%m%d%H%M%S")
# shellcheck disable=SC2034
M_TIMESTAMP=$(date "+%Y%m%d%H%M")

# Check if the script is being sourced
# This prevents the script from being executed if it is run directly.
# It ensures that the functions defined in this script are only available when sourced.
# This is a common practice in shell scripting to avoid unintended execution.
# ================================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script is intended to be sourced, not executed directly."
    exit 1
fi

[[ -n "$UTILS_LOADED" ]] && return
UTILS_LOADED=1

# Function to set up logging
# This function initializes logging by creating a log directory and setting up
# a log file with a timestamp. It redirects all output to the log file.
# It takes one argument: the log directory path.
# Usage: setup_logging "/path/to/log/directory"

# Arguments:
#   - log_dir: The path to the directory where logs will be stored.

# Returns:
#   - None

# Example:
#   setup_logging "/tmp/my_logs"
# ================================================================================
setup_logging() {
    local log_dir="$1"
    local timestamp=${S_TIMESTAMP}
    local log_file
    log_file="${log_dir}/$(basename "$0" ."${0##*.}")_${timestamp}.log"

    dir_create_if_not_exist "$log_dir" || {
        echo "Failed to create log directory: $log_dir"
        return 1
    }
    exec > >(tee -i "$log_file") 2>&1
    echo "=========================================================================================="
    echo "Logging initialized. Output will be written to: $log_file"
    echo "=========================================================================================="
}

# Define colors for logging
# This section defines color codes for different log levels.
# These colors are used to format the log messages for better readability.
# Colors
USE_COLOR=true
if [[ ! -t 1 ]]; then
    USE_COLOR=false
fi
# Colors (only if supported)
if [[ "$USE_COLOR" == true ]]; then
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    GREEN='\033[0;32m'
    CYAN='\033[0;36m'
    RESET='\033[0m'
else
    # shellcheck disable=SC2034
    RED=''
    # shellcheck disable=SC2034
    YELLOW=''
    # shellcheck disable=SC2034
    GREEN=''
    # shellcheck disable=SC2034
    CYAN=''
    # shellcheck disable=SC2034
    RESET=''
fi

# Check if the output is a terminal
# This section checks if the output is a terminal. If not, it disables color output.

# Function to write logs
# This function logs messages with a timestamp and log level.
# It takes two arguments: the log level and the message.
# Usage: log_message "INFO" "This is an info message"

# Arguments:
#   - log_level: The level of the log (INFO, ERROR, WARN, DEBUG).
#   - log_message: The message to be logged.

# Returns:
#   - None

# Example:
#   log_message "INFO" "This is an info message"

log_message() {
    local log_level="$1"
    local log_message="$2"
    local timestamp="${S_TIMESTAMP}"
    echo -e "${timestamp} [$log_level] $log_message"
}

# Function to log INFO level messages
# This function logs messages with INFO level.
# It takes one argument: the message to be logged.
# Usage: log_info "This is an info message"

# Arguments:
#   - message: The message to be logged.

# Returns:
#   - None

# Example:
#   log_info "This is an info message"

log_info() {
    log_message "[INFO]" "$*"
}

# =================================================================================
# log_error Function
# ================================================================================

# Function to log ERROR level messages
# This function logs messages with ERROR level.
# It takes one argument: the message to be logged.
# Usage: log_error "This is an error message"

# Arguments:
#   - message: The message to be logged.

# Returns:
#   - None

# Example:
#   log_error "This is an error message"
# ================================================================================

log_error() {
    log_message "[ERROR]" "$*"
}

# Function to log WARN level messages
log_warning() {
    log_message "[WARN]" "$*"
}

# Function to log DEBUG level messages (optional, could be enabled only in dev)
log_debug() {
    # Uncomment the next line to enable debug logging
    log_message "DEBUG" "$1"
    :
}

log_success() {
    log_message "[OK] $*"
}

# =================================================================================
# validate_input Function
# ================================================================================
# Function to check if the directory path is provided
# This function checks if the provided directory path is valid.
# It takes one argument: the directory path.
# Usage: validate_input "/path/to/directory"

# Arguments:
#   - dir_path: The path to the directory to be validated.

# Returns:
#   - 0 if the directory path is valid.
#   - 1 if the directory path is not valid.

# Example:
#   validate_input "/tmp/my_directory"
# ================================================================================
validate_input() {
    local dir_path="$1"
    if [[ -z "$dir_path" ]]; then
        log_error "No directory path provided."
        return 1
    fi
    return 0
}

# =================================================================================
# path_exists Function
# =================================================================================
# Function: Check if a path exists
# This function checks if the provided path exists.
# It takes one argument: the path to be checked.
# Usage: path_exists "/path/to/file_or_directory"

# Arguments:
# - path: The path to be checked.

# Returns:
# - 0 if the path exists.
# - 1 if the path does not exist.

# Example:
# path_exists "/tmp/my_file.txt"
# ================================================================================
path_exists() {
    local path="$1"

    if [[ -e "$path" ]]; then
        return 0 # Path exists
    else
        return 1 # Path does not exist
    fi
}

# =================================================================================
# is_file Function
# ================================================================================
# Function: Check if the path is a file
# This function checks if the provided path is a file.
# It takes one argument: the file path.
# Usage: is_file "/path/to/file.txt"

# Arguments:
# - file_path: The path to the file to be checked.

# Returns:
# - 0 if the path is a file.
# - 1 if the path is not a file.

# Example:
# is_file "/tmp/my_file.txt"
# =
is_file() {
    local path="$1"

    if [[ -f "$path" ]]; then
        return 0 # Path is a file
    else
        return 1 # Path is not a file
    fi
}

# =================================================================================
# create_file Function
# ================================================================================
# This function creates a file at the specified path.
# It takes one argument: the file path.
# Usage: create_file "/path/to/file.txt"
# Arguments:
#   - file_path: The path to the file to be created.
# Returns:
#   - 0 if the file is created successfully.
#   - 1 if there was an error in the process.
# Example:
#   create_file "/tmp/my_file.txt"
# ================================================================================
create_file() {
    local file_path="$1"

    # shellcheck disable=SC2015
    touch "$file_path" && log_info "File created: $file_path" || log_error "Failed to create file: $file_path."
}

# ================================================================================
# file_create_if_not_exist Function
# ================================================================================
# Function: Validate or create the file
# This function checks if the provided path is a file.
# If it does not exist, it creates the file.
# It takes one argument: the file path.
# Usage: file_create_if_not_exist "/path/to/file.txt"

# Arguments:
#   - file_path: The path to the file to be validated or created.

# Returns:
#   - 0 if the file exists or is created successfully.
#   - 1 if there was an error in the process.

# Example:
#   file_create_if_not_exist "/tmp/my_file.txt"
# ================================================================================
file_create_if_not_exist() {
    local file_path="$1"

    # Validate input
    if ! validate_input "${file_path}"; then
        log_error "No file path provided. Please specify a valid file path."
        return 1 # Exit with error
    fi

    # Check if the path exists and is a file
    # If the path does not exist and is not a file, create the file
    if ! path_exists "${file_path}" && ! is_file "${file_path}"; then
        log_info "File ${file_path} does not exist. Creating it."
        # Path does not exist, create the file
        create_file "${file_path}"
        return 0
    fi

    log_info "File ${file_path} exists. No action needed."
    return 0
}

# ================================================================================
# dir_create_if_not_exist Function
# ================================================================================
# Function: Check if the path is a directory, create if it does not exist
# This function checks if the provided path is a directory.
# If it does not exist, it creates the directory.
# It takes one argument: the directory path.
# Usage: dir_create_if_not_exist "/path/to/directory"

# Arguments:
#   - dir_path: The path to the directory to be validated or created.

# Returns:
#   - 0 if the directory exists or is created successfully.
#   - 1 if there was an error in the process.
# Example:
#   dir_create_if_not_exist "/tmp/my_directory"
# ================================================================================
dir_create_if_not_exist() {
    local dir_path="$1"

    # Validate input
    if ! validate_input "${dir_path}"; then
        log_error "No file path provided. Please specify a valid file path."
        return 1 # Exit with error
    fi

    # Check if the directory exists and is a directory
    if ! path_exists "${dir_path}" && ! is_directory "${dir_path}"; then
        log_info "Directory ${dir_path} does not exits. Creating it."
        create_directory "${dir_path}"
        return 0
    fi

    log_info "Directory ${dir_path} exists. No action needed."
    return 0
}

# =================================================================================
# is_directory Function
# ================================================================================
# This function checks if the provided path is a directory.
# It takes one argument: the directory path.
# Usage: is_directory "/path/to/directory"

# Arguments:
#   - dir_path: The path to the directory to be checked.

# Returns:
#   - 0 if the path is a directory.
#   - 1 if the path is not a directory.

# Example:
#   is_directory "/tmp/my_directory"

is_directory() {
    local dir_path="$1"
    if [[ -d "$dir_path" ]]; then
        return 0 # true
    else
        return 1 # false
    fi
}

# ================================================================================
# clean_directory Function
# ================================================================================
# Function to clean the directory
# This function removes all files and subdirectories within the specified directory.
# It takes one argument: the directory path.
# Usage: clean_directory "/path/to/directory"

# Arguments:
#   - dir_path: The path to the directory to be cleaned.

# Returns:
#   - 0 if the directory is successfully cleaned.
#   - 1 if there was an error in the process.

# Example:
#   clean_directory "/tmp/my_directory"

clean_directory() {
    local dir_path="$1"
    log_info "Cleaning directory: $dir_path"
    # shellcheck disable=SC2115
    rm -rf "$dir_path"/*
}

# ================================================================================
# create_directory Function
# ================================================================================
# Function to create the directory
# This function creates a directory at the specified path.
# It takes one argument: the directory path.
# Usage: create_directory "/path/to/directory"

# Arguments:
#   - dir_path: The path to the directory to be created.

# Returns:
#   - 0 if the directory is successfully created or already exists.
#   - 1 if there was an error in the process.

# Example:
#   create_directory "/tmp/my_directory"

create_directory() {
    local dir_path="$1"
    log_info "Creating directory: $dir_path"
    mkdir -p "$dir_path"
}

# ================================================================================
# prepare_directory Function
# ================================================================================
# Function to prepare the directory
# This function checks if the directory exists, and if it does, it cleans it.
# If it doesn't exist, it creates the directory.
# It also validates the input and logs the actions taken.
# It takes one argument: the directory path.
# Usage: prepare_directory "/path/to/directory"

# Arguments:
#   - dir_path: The path to the directory to be prepared.

# Returns:
#   - 0 if the directory is successfully prepared.
#   - 1 if there was an error in the process.

# Example:
#   prepare_directory "/tmp/my_directory"

prepare_directory() {
    local dir_path="$1"

    log_info "Starting to prepare directory: $dir_path"
    # Validate input
    validate_input "$dir_path" || return 1

    # Check if the path exists and is a directory
    if is_directory "$dir_path"; then
        # Clean the directory
        clean_directory "$dir_path"
    else
        # Create the directory
        create_directory "$dir_path"
    fi

    # Confirm the operation
    log_info "Directory is ready: $dir_path"
}

# ================================================================================
# is_directory_empty Function
# ================================================================================
# This function checks if the provided directory is empty.
# It takes one argument: the directory path.
# Usage: is_directory_empty "/path/to/directory"

# Arguments:
#   - dir_path: The path to the directory to be checked.

# Returns:
#   - 0 if the directory is empty.
#   - 1 if the directory is not empty.

# Example:
#   is_directory_empty "/tmp/my_directory"

is_directory_empty() {
    local dir_path="$1"
    # Use find to check if the directory is empty
    if [ -z "$(find "$dir_path" -mindepth 1 -print -quit)" ]; then
        return 0 # Directory is empty
    else
        return 1 # Directory is not empty
    fi
}

# ================================================================================
# is_empty_file Function
# ================================================================================
# This function checks if the provided path is empty.
# It checks if the file exists and if it is empty.
# If the file does not exist, it returns an error.
# If the file exists and is empty, it returns success.
# If the file exists and is not empty, it returns an error.
# This function is useful for checking if a file is empty before processing it.
# It is a simple utility function that can be used in various scripts.

# It takes one argument: the file path.
# Usage: is_empty_file "/path/to/file.txt"
# Arguments:
#   - file_path: The path to the file to be checked.
# Returns:
#   - 0 if the file is empty.
#   - 1 if the file is not empty or does not exist.
# Example:
#   is_empty_file "/tmp/my_file.txt"

is_empty_file() {
    local file_path="$1"

    # Validate input
    if ! validate_input "$file_path"; then
        log_error "No file path provided. Please specify a valid file path."
        return 1 # Exit with error
    fi

    # Check if the path exists
    if ! path_exists "$file_path"; then
        log_error "File does not exist: $file_path."
        return 1 # Exit with error
    fi

    # Check if the path is a file
    if ! is_file "$file_path"; then
        log_error "Path exists but is not a file: $file_path."
        return 1 # Exit with error
    fi

    # Check if the file is empty
    if [[ -s "$file_path" ]]; then
        return 1 # File is not empty
    else
        return 0 # File is empty
    fi
}

# ================================================================================
# Function to backup data directory
# ================================================================================
# This function backs up the data directory by moving all files and directories
# to a specified backup directory. It validates the input, checks if the backup
# directory exists, and creates it if necessary. It also logs the actions taken.
# It takes two arguments: the backup directory path and the source directory path.
# Usage: backup_data_dir "/path/to/backup_directory" "/path/to/source_directory"
# Arguments:
#   - backup_dir: The path to the backup directory.
#   - source_dir: The path to the source directory to be backed up.
# Returns:
#   - 0 if the backup is successful.
#   - 1 if there was an error in the process.
# Example:
#   backup_data_dir "/tmp/my_backup_directory" "/path/to/source_directory"
# ================================================================================

backup_data_dir() {
    local backup_dir="$1" # Remove trailing slash if present
    local source_dir="$2"

    # Validate input
    if ! validate_input "${backup_dir}" || ! validate_input "$source_dir"; then
        log_error "No backup directory or source directory provided. Please specify valid paths."
        return 1 # Exit with error
    fi

    # Check if the backup directory exists
    dir_create_if_not_exist "${backup_dir}" || {
        log_error "Failed to create backup directory: '${backup_dir}'"
        return 1 # Exit with error
    }

    # Move files and directories to the backup directory
    mv "${source_dir}"/* "${backup_dir}" || {
        log_error "Failed to move files and directories to backup directory: '${backup_dir}'"
        return 1 # Exit with error
    }

    # Confirm the operation
    log_info "Backup completed successefully . Files and directories moved to: ${backup_dir}"
    return 0 # Exit with success
}

# ================================================================================
# Validate URL Function
# ================================================================================
# This function checks if the provided URL is valid.
# Arguments:
#   $1: URL to validate
# Returns:
#   0: Valid URL
#   1: Invalid URL
# ================================================================================
is_valid_url() {
    local url="$1"
    [[ "$url" =~ ^https?://[a-zA-Z0-9./?=_-]+$ ]]
}

# ==============================================================================
# Function: replace_characters_sed
# Purpose : Replace all occurrences of a character/string in input with another
#           using sed (supports complex patterns safely).
# Arguments:
#   $1 - Input string
#   $2 - Character/string to replace (pattern)
#   $3 - Replacement character/string
# Returns :
#   Prints the transformed string
# ==============================================================================
replace_characters_sed() {
    local input="$1"
    local from_pattern="$2"
    local to_pattern="$3"

    # Validate inputs
    if ! validate_input "$input"; then
        log_error "No input string provided." >&2
        return 1
    fi

    if ! validate_input "$from_pattern"; then
        log_error "No pattern to replace specified." >&2
        return 1
    fi

    if ! validate_input "$to_pattern"; then
        log_warning "No replacement string provided. Defaulting to empty string." >&2
        to_pattern=""
    fi

    # Escape forward slashes to avoid sed delimiter conflicts
    local escaped_from_pattern
    local escaped_to_pattern
    escaped_from_pattern=$(printf '%s\n' "$from_pattern" | sed 's/[\/&]/\\&/g')
    escaped_to_pattern=$(printf '%s\n' "$to_pattern" | sed 's/[\/&]/\\&/g')

    # Perform replacement using sed
    # shellcheck disable=SC2001
    echo "$input" | sed "s/${escaped_from_pattern}/${escaped_to_pattern}/g"
}

# ==============================================================================
