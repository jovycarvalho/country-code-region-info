#!/usr/bin/env bats

load './helpers/mock_utils.bash'

setup() {
  # Fix: Use absolute path resolution for SCRIPT_DIR
  TEST_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")" && pwd)"
  export SCRIPT_DIR="${TEST_DIR}/../src"

  # Export required functions
  export -f validate_input is_directory path_exists is_file is_empty_file log_info log_warn log_error setup_logging

  # Set up PATH for mock commands
  export PATH="$BATS_TMPDIR/fakebin:$PATH"
  mkdir -p "$BATS_TMPDIR/fakebin"
}

teardown() {
  rm -rf "$BATS_TMPDIR/fakebin"
}

@test "succeeds with valid URL and path using curl" {
  # Create output directory
  mkdir -p "$BATS_TMPDIR/output"

  # Create mock curl command
  cat <<'EOF' > "$BATS_TMPDIR/fakebin/curl"
#!/bin/bash
touch "$4"
EOF
  chmod +x "$BATS_TMPDIR/fakebin/curl"

  # Run the test with absolute paths
  run bash "${SCRIPT_DIR}/download.sh" "https://example.com/file.csv" "$BATS_TMPDIR/output/test.csv"

  [ "$status" -eq 0 ]
  [[ "$output" =~ "CSV downloaded successfully" ]]
}

@test "fails on invalid URL format" {
  run bash "${SCRIPT_DIR}/download.sh" "ftp://example.com/file.csv" "$BATS_TMPDIR/output/test.csv"
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Invalid URL" ]]
}

@test "fails on invalid output directory" {
  run bash "${SCRIPT_DIR}/download.sh" "https://example.com/file.csv" "/bad/dir/file.csv"
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Output  does not exist" ]]
}

@test "warns on non-.csv extension" {
  mkdir -p "$BATS_TMPDIR/output"
  cat <<'EOF' > "$BATS_TMPDIR/fakebin/curl"
#!/bin/bash
touch "$4"
EOF
  chmod +x "$BATS_TMPDIR/fakebin/curl"

  run bash "${SCRIPT_DIR}/download.sh" "https://example.com/test.txt" "$BATS_TMPDIR/output/test.txt"
  [[ "$output" =~ "Downloaded file does not have a .csv extension" ]]
}

@test "warns if file is empty" {
  mkdir -p "$BATS_TMPDIR/output"
  cat <<'EOF' > "$BATS_TMPDIR/fakebin/curl"
#!/bin/bash
touch "$4"
EOF
  chmod +x "$BATS_TMPDIR/fakebin/curl"

  run bash "${SCRIPT_DIR}/download.sh" "https://example.com/test.csv" "$BATS_TMPDIR/output/empty.csv"
  [[ "$output" =~ "Downloaded file is empty" ]]
}

@test "fails if neither curl nor wget is available" {
  run bash "${SCRIPT_DIR}/download.sh" "https://example.com/file.csv" "$BATS_TMPDIR/output/test.csv"
  [[ "$output" =~ '[ERROR] Neither curl nor wget is installed' ]]
}

@test "fails if curl fails" {
  mkdir -p "$BATS_TMPDIR/output"
  cat <<'EOF' > "$BATS_TMPDIR/fakebin/curl"
#!/bin/bash
exit 1
EOF
  chmod +x "$BATS_TMPDIR/fakebin/curl"

  run bash "${SCRIPT_DIR}/download.sh" "https://example.com/file.csv" "$BATS_TMPDIR/output/test.csv"
  [[ "$output" =~ "Failed to download CSV" ]]
}

@test "fails if downloaded file is missing" {
  cat <<'EOF' > "$BATS_TMPDIR/fakebin/curl"
#!/bin/bash
true
EOF
  chmod +x "$BATS_TMPDIR/fakebin/curl"

  run bash "${SCRIPT_DIR}/download.sh" "https://example.com/file.csv" "$BATS_TMPDIR/missing/file.csv"
  [[ "$output" =~ "Downloaded file is invalid or missing" ]]
}


@test "fails if file is not a file" {
  mkdir -p "$BATS_TMPDIR/output"
  cat <<'EOF' > "$BATS_TMPDIR/fakebin/curl"
#!/bin/bash
touch "$4"
EOF
  chmod +x "$BATS_TMPDIR/fakebin/curl"

  run bash "${SCRIPT_DIR}/download.sh" "https://example.com/file.csv" "$BATS_TMPDIR/notfile/file.csv"
  [[ "$output" =~ "Downloaded file is invalid or missing" ]]
}

@test "fails if validate_input fails on url" {
  run bash "${SCRIPT_DIR}/download.sh" "invalid" "$BATS_TMPDIR/output/test.csv"
  [[ "$output" =~ "Usage: download_csv" ]]
}
