#!/bin/bash

validate_input() { [[ "$1" != "invalid" ]]; }
is_directory() { [[ -d "$1" && "$1" != *"/bad/"* ]]; }
path_exists() { [[ "$1" != *"/missing/"* ]]; }
is_file() { [[ "$1" != *"/notfile/"* ]]; }
is_empty_file() { [[ "$1" == *"/empty/"* ]]; }

log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*"; }
log_error() { echo "[ERROR] $*"; }

setup_logging() { :; }
