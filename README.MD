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

1. Downloading a CSV file via a URL provided by the user.
2. Processing the file, allowing for the search and extraction of data.
3. Saving and presenting the search result in the form of a table.

Additionally, a set of auxiliary functionalities is implemented, including file and directory management, such as the creation, copying, and deletion of files and directories.

The design cover:
- Core Bash skills
- Code organization
- Scalability, Reusability, Maintainability
- Best practices in security, performance, clarity

---

## 📁 Project Structure

```bash
├── country-code-region-info
│  ├── bin
│  │  └── get_country_code_info.sh
│  ├── README.MD
│  └── src
│     ├── download.sh
│     ├── print_csv_files.sh
│     ├── remove_whitespace.sh
│     ├── search.sh
│     └── utils.sh
```

---
## 🚀 Getting Started

```bash
# Clone the repository
git clone git@github.com:jovycarvalho/country-code-region-info.git
cd country-code-region-info

# Make sure your scripts are executable
chmod +x search.sh

# Run the search
./search.sh -i data/source/source.csv -s "Cabo Verde" -o output.csv
```

---

## 🧐 Core Concepts

### 📄 Scripts vs Libraries
- `search.sh` is an **executable script** (`chmod +x`).
- `src/utils.sh` is a **library**, meaning:
  - It **must be imported** using `source`
  - It **cannot** be executed directly
  - It provides **reusable basic functionality** (e.g., file operations, validation)

**File:** [`lib/utils.sh`](lib/utils.sh)

---

### 🛠️ Variable Declaration Best Practices

Variables are:
- Quoted to avoid globbing and word splitting
- Lowercase or snake_case
- Descriptive names
- Declared local whenever possible to avoid global pollution

Example:

```bash
local input_file="$1"
local search_terms="$2"
local output_file="$3"
```

> 📍 **File**: [`search.sh`](search.sh) — Lines 2-4 — **inside `search_in_csv()`**

---

### 🔄 Functions: Creation, Reuse, Importing

Functions:
- Are small, focused, and named clearly
- Validate their inputs
- Return `0` (success) or `non-zero` (error)

Example of a small reusable function:

```bash
validate_input() {
    local input="$1"
    [[ -n "${input}" ]]
}
```

**Importing Libraries:**
```bash
# At the top of your script
source "$(dirname "$0")/lib/utils.sh"
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

