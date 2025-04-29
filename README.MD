# 📚 Country Code Region Info
> **A Practical Shell Script Project to Master Bash Scripting: From Basics to Advanced Techniques**

---

## 📌 Table of Contents
- [About the Project](#about-the-project)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Core Concepts](#core-concepts)
  - [Scripts vs Libraries](#scripts-vs-libraries)
  - [Variable Declaration Best Practices](#variable-declaration-best-practices)
  - [Functions: Creation, Reuse, Importing](#functions-creation-reuse-importing)
- [Important Files Overview](#important-files-overview)
  - [utils.sh: The Core Utility Library](#utilssh-the-core-utility-library)
- [Example Excerpts Explained](#example-excerpts-explained)
- [Best Practices Followed](#best-practices-followed)
- [Security and Robustness](#security-and-robustness)
- [Performance and Scalability](#performance-and-scalability)
- [Learning Path](#learning-path)
- [Contributing](#contributing)
- [License](#license)

---

## 📖 About the Project
This project is a **real-world, hands-on educational journey** in **professional Bash scripting**.  
We focus on building a **tool** that searches and manages **country and region code information**.
The project in question fundamentally implements three main processes:

1. Validates input arguments (URL, search term, output format).
2. Downloads a CSV file from a remote source.
3. Searches for rows containing a specific term.
4. Formats and optionally prints the results.
5. Outputs search results as csv (optionally formatted to JSON externally).
6. Performs directory setup and backs up previous data if needed.
7. Comprehensive logging for traceability and error diagnosis.

Additionally, a set of auxiliary functionalities is implemented, including file and directory management, such as the creation, copying, and deletion of files and directories.

The design cover:
- Core Bash skills
- Code organization
- Scalability, Reusability, Maintainability
- Best practices in security, performance, clarity

---

## 📁 Project Structure

```bash
project-root/
│
├── processor.sh              # Main script
├── logs/                     # Contains runtime log files
├── data/
│   ├── source/               # Raw downloaded CSVs
│   ├── precessed/            # Search result CSVs
│   └── bacuckup/             # Backups of old CSVs
├── src/
│   ├── utils.sh              # Utilities (validation, logging)
│   ├── download.sh           # Download logic
│   ├── search.sh             # Search logic
│   └── print_csv_files.sh    # Display CSV results in table format
```

---
## 🚀 Getting Started
`processor.sh` is a Bash script that automates the process of downloading a CSV file from a provided URL, searching for a specific term within that file, and formatting the output as either JSON or CSV. It is designed with modularity, logging, validation, and backup support in mind.

```bash
# Clone the repository
git clone git@github.com:jovycarvalho/country-code-region-info.git
cd/bin country-code-region-info
chmod +x search.sh
./processor.sh <csv_url> <search_term> [output_format: json|csv]

Example:
    ./get_country_code_info.sh https://cdn.wsform.com/wp-content/uploads/2018/09/country_full.csv "Cabo Verde" csv
```
# Output

```bash
Logging initialized. Output will be written to: /home/jovy/Documents/Cursos/DevOps/exercices/country-code-region-info/src/../logs/get_country_code_info_20250429174657.log
==========================================================================================
20250429174657 [[INFO]] ======================================================================
20250429174657 [[INFO]] INITIALIZING CSV PROCESSOR SCRIPT
20250429174657 [[INFO]] ======================================================================
## 20250429174657 [[INFO]] Parsing arguments
20250429174657 [[INFO]] ======================================================================
## 20250429174657 [[INFO]] Arguments parsed successfully
20250429174657 [[INFO]] ======================================================================
## 20250429174657 [[INFO]] Preparing directories and files
20250429174657 [[INFO]] ======================================================================
20250429174657 [[INFO]] Directory ../data/source does not exits. Creating it.
20250429174657 [[INFO]] Creating directory: ../data/source
20250429174657 [[INFO]] Directory ../data/bacuckup does not exits. Creating it.
20250429174657 [[INFO]] Creating directory: ../data/bacuckup
20250429174657 [[INFO]] Creating new data file: '../data/source/source.csv'
20250429174657 [[INFO]] File created: ../data/source/source.csv
20250429174657 [[INFO]] Directories prepared successfully
20250429174657 [[INFO]] ======================================================================
## 20250429174657 [[INFO]] Starting download from: 'https://cdn.wsform.com/wp-content/uploads/2018/09/country_full.csv'
## 20250429174657 [[INFO]] ======================================================================
Downloading CSV from URL: https://cdn.wsform.com/wp-content/uploads/2018/09/country_full.csv
Output path: ../data/source/source.csv
20250429174657 [[INFO]] Downloading CSV from 'https://cdn.wsform.com/wp-content/uploads/2018/09/country_full.csv' to '../data/source/source.csv'
20250429174657 [[INFO]] CSV downloaded successfully to '../data/source/source.csv'
20250429174657 [[INFO]] Download completed successfully
20250429174657 [[INFO]] ======================================================================
## 20250429174657 [[INFO]] Serching for 'Cabo Verde' in CSV: '../data/source/source.csv'
##20250429174657 [[INFO]] ======================================================================
20250429174657 [[INFO]] Searching for 'Cabo Verde' in CSV: '../data/source/source.csv'
20250429174657 [[INFO]] Directory ../data/precessed does not exits. Creating it.
20250429174657 [[INFO]] Creating directory: ../data/precessed
20250429174657 [[INFO]] File ../data/precessed/results_Cabo_Verde_20250429174657.csv does not exist. Creating it.
20250429174657 [[INFO]] File created: ../data/precessed/results_Cabo_Verde_20250429174657.csv
20250429174657 [[WARN]] ripgrep (rg) not found. Falling back to awk search (may be slower).
20250429174657 [[INFO]] Search completed. Results saved to '../data/precessed/results_Cabo_Verde_20250429174657.csv'
20250429174657 [[INFO]] Search completed successfully
20250429174657 [[INFO]] ======================================================================
## 20250429174657 [[INFO]] Printing search result in table fomat
## 20250429174657 [[INFO]] ======================================================================
NAME         ALPHA-2   ALPHA-3   COUNTRY-CODE   ISO_3166-2      REGION   SUB-REGION           INTERMEDIATE-REGION   REGION-CODE   SUB-REGION-CODE   INTERMEDIATE-REGION-CODE   
------------ --------- --------- -------------- --------------- -------- -------------------- --------------------- ------------- ----------------- -------------------------- 
Cabo Verde   CV        CPV       132            ISO 3166-2:CV   Africa   Sub-Saharan Africa   Western Africa        002           202               011                        
20250429174657 [[INFO]] Search results printed successfully
20250429174657 [[INFO]] Processing completed successfully
20250429174657 [[INFO]] ======================================================================
20250429174657 [[INFO]] CSV PROCESSOR SCRIPT FINISHED!
20250429174657 [[INFO]] ======================================================================
```
---

## 📚 Important Files Overview

### ✨ `src/utils.sh`: The Core Utility Library

🔵 Purpose:
- **General-purpose helper functions**.
- Not executable — only **sourced** by scripts.

🔵 Key Characteristics:
- No hardcoded variables or paths.
- Functions are **idempotent** (safe to call multiple times).
- Clear and strict input validation.

🔵 Highlighted Functions:
| Function | Purpose | File Link + Line |
| :--- | :--- | :--- |
| `path_exists()` | Check if a given path exists | [lib/utils.sh#L10](src/utils.sh#L10) |
| `is_file()` | Check if a path is a regular file | [src/utils.sh#L18](src/utils.sh#L18) |
| `is_empty_file()` | Check if file is empty | [src/utils.sh#L26](src/utils.sh#L26) |
| `dir_create_if_not_exist()` | Create directory if it doesn't exist | [src/utils.sh#L34](src/utils.sh#L34) |
| `file_create_if_not_exist()` | Create an empty file if missing | [src/utils.sh#L42](src/utils.sh#L42) |
| `log_info()`, `log_warning()`, `log_error()` | Centralized logging functions | [src/utils.sh#L50-L78](src/utils.sh#L50) |

## 🧐 Core Concepts

### 📄 Scripts vs Libraries
- `search.sh` is an **executable script** (`chmod +x`).
- `src/utils.sh` is a **library**, meaning:
  - It **must be imported** using `source`
  - It **cannot** be executed directly
  - It provides **reusable basic functionality** (e.g., file operations, validation)

**File:** [`src/utils.sh`](src/utils.sh)
```bash
cd ../src/
# Make sure your scripts are executable
chmod +x search.sh
# Run the search
./search.sh -i ../data/source/source.csv -s "Cabo Verde" -o output.csv
```

# Output

```bash
./search.sh -i ../data/source/source.csv -s "Cabo Verde" -o output.csv

20250429185333 [[INFO]] ======================================================================
20250429185333 [[INFO]] Parsing arguments
20250429185333 [[INFO]] ======================================================================
20250429185333 [[INFO]] Searching for 'Cabo Verde' in CSV: '../data/source/source.csv'
20250429185333 [[INFO]] Directory . exists. No action needed.
20250429185333 [[INFO]] File output.csv_cabo_verde.csv does not exist. Creating it.
20250429185333 [[INFO]] File created: output.csv_cabo_verde.csv
20250429185333 [[WARN]] ripgrep (rg) not found. Falling back to awk search (may be slower).
20250429185333 [[INFO]] Search completed. Results saved to 'output.csv_cabo_verde.csv'
```

---

### 🛠️ Variable Declaration and uses: Best Practices

### Variable Declaration
Variables are:
- Quoted to avoid globbing and word splitting
- Lowercase or snake_case
- Descriptive names
- Declared local whenever possible to avoid global pollution
- Use local for Function-Scoped Variables
- Use Descriptive and Consistent Variable Names

Example:

```bash
download() {
    local input_file="$1"
    local search_terms="$2"
    local output_file="$3"
    ...
```

> 📍 **File**: [`search.sh`](search.sh) — Lines 2-4 — **inside `search_in_csv()`**

### How to use Variables

- Always Quote Variables
- Validate Inputs Clearly and Early
- Use readonly for Constants (when applicable)
- Initialize Variables Near Their Use
- Group Related Logic
- Return Non-Zero on Errors

```bash
download() {
    local url="$1"
    local output_path="$2"

    log_info "Downloading CSV from URL: ${url}"
    log_info "Output path: ${output_path}"

    # Validate input values
    if ! validate_input "${url}" || ! validate_input "${output_path}"; then
        log_error "Usage: download <url> <output_path>"
        return 1
    fi

    if [[ ! "${url}" =~ ^https?:// ]]; then
        log_error "Invalid URL: '${url}'"
        return 1
    fi

    local output_dir
    output_dir="$(dirname "${output_path}")"

    if ! is_directory "${output_dir}"; then
        log_error "Output directory does not exist: '${output_dir}'"
        return 1
    fi

    log_info "Downloading CSV from '${url}' to '${output_path}'"
    # download logic here
}

```
---

### 🔄 Functions: Creation, Reuse, Importing

Functions:
- Are small, focused, and named clearly
- Validate their inputs
- Return `0` (success) or `non-zero` (error)

Example of a small reusable function:

```bash
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


is_directory() {
    local dir_path="$1"
    if [[ -d "$dir_path" ]]; then
        return 0 # true
    else
        return 1 # false
    fi
}


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

```

## **Importing Libraries:**
```bash
# At the top of your script
# Load configuration and functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../src/utils.sh"
source "${SCRIPT_DIR}/../src/download.sh"
source "${SCRIPT_DIR}/../src/search.sh"
source "${SCRIPT_DIR}/../src/print_csv_files.sh"
```
---

Example: **Create a Directory If Missing**
```bash
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
```

✅ **Best Practice Applied**:
- Always **check** before creating directories.
- Avoids crashing if dir already exists.

---

## 🔍 Example Excerpts Explained

### 1. Input Validation (`search.sh`)

```bash
if ! validate_input "${input_file}" || ! validate_input "${search_terms}" || ! validate_input "${output_file}"; then
    usage
    log_error "Invalid arguments. Please provide valid input, search terms, and output file."
    return 1
fi
```
- 📍 File: [`search.sh`](search.sh#L13-L17)
- 💬 **Explanation**: Never trust user input. Always validate early.

---

### 2. Using `awk` for Search as Fallback

```bash
awk -v term="${search_terms}" '
    BEGIN {
        FPAT = "([^,]*)|(\"[^\"]+\")";
        IGNORECASE = 1;
    }
    ...
' "${input_file}" >>"${output_file}"
```
- 📍 File: [`search.sh`](search.sh#L38-L50)
- 💬 **Explanation**: Uses `FPAT` to handle CSV fields properly even if commas inside quotes.

---

### 3. Defensive Programming

```bash
if [[ "${line_count}" -le 1 ]]; then
    log_warning "No matches found for '${search_terms}' in '${input_file}'."
    rm -f "${output_file}"
    return 0
fi
```
- 📍 File: [`search.sh`](search.sh#L65-L70)
- 💬 **Explanation**: If no match found, clean up unnecessary output.

---

## 🏆 Best Practices Followed

- **Fail Fast:** Validate inputs early.
- **Quote all variables** to prevent globbing or splitting.
- **Use functions** instead of inline code blocks.
- **Import libraries** via `source`.
- **Centralized Logging** for clarity.
- **Local variables inside functions** to avoid global contamination.

---

## 🔐 Security and Robustness
- No external execution without checking `command -v`.
- No unchecked user inputs.
- Explicit permission setting for created files/directories.
- Graceful handling of missing data (empty files, missing dirs).

---

## ⚡ Performance and Scalability
- `ripgrep` preferred if available for **high-performance search**.
- Fallback to `awk`, ensuring compatibility.
- Modular architecture: adding new search types or formats (like JSON) would only require minimal new functions.

---

## 📈 Learning Path

| Skill Level | Features to Study | Suggested Activities |
| :--- | :--- | :--- |
| Beginner | Variables, Functions, File IO | Study `search.sh`, modify small things |
| Intermediate | Defensive programming, Libraries | Extend `utils.sh` |
| Advanced | Scalability, Performance, Professional practices | Add new modules, e.g., JSON export |

---

## 🤝 Contributing
Pull requests are welcome!  
Follow the same style guide: modular, documented, validated, secure.

---

## 📜 License
[MIT License](LICENSE)

---

# 🏯 Final Notes
This project is not just a tool — it’s a **learning framework** designed to **build mastery** progressively while **practicing best engineering habits** from the beginning.  
By contributing to or using this repository, you're actively improving your **DevOps** and **Scripting** skills the right way.

