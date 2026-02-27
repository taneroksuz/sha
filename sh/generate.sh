#!/usr/bin/env bash
# =============================================================================
#  sha_demo.sh
#  Install OpenSSL, generate random plaintext, compute SHA-1 / SHA-256 / SHA-512
#  Saves each hash and plaintext as separate .hex files
#
#  Usage: ./generate.sh [PLAINTEXT_BYTES]
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'
YELLOW='\033[1;33m'; MAGENTA='\033[0;35m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
ok()      { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
err()     { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
section() { echo -e "\n${BOLD}── $* ──${RESET}"; }

usage() {
    echo -e "${BOLD}Usage:${RESET} $0 [PLAINTEXT_BYTES]"
    echo ""
    echo -e "  ${CYAN}PLAINTEXT_BYTES${RESET}  Size of random plaintext in bytes (default: 64)"
    echo -e "                   Any positive integer is accepted"
    echo ""
    echo -e "${BOLD}Examples:${RESET}"
    echo "  $0        # 64 bytes (default)"
    echo "  $0 128    # 128 bytes"
    echo "  $0 1024   # 1 KB"
    echo ""
    echo -e "${BOLD}Output files (in ./sha_output/):${RESET}"
    echo "  plaintext.bin       raw random binary"
    echo "  plaintext.hex       raw hex string (no spaces)"
    echo "  plaintext.txt       xxd formatted dump (offset + hex + ASCII)"
    echo "  sha256.hex          SHA-256 digest hex"
    echo "  sha512.hex          SHA-512 digest hex"
    echo "  hashes.txt          all three digests together"
}

# ── Parse & validate arguments ────────────────────────────────────────────────
[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage && exit 0

PLAINTEXT_BYTES="${1:-64}"

if ! [[ "${PLAINTEXT_BYTES}" =~ ^[1-9][0-9]*$ ]]; then
    err "PLAINTEXT_BYTES must be a positive integer. Got: '${PLAINTEXT_BYTES}'"
    echo ""
    usage
    exit 1
fi

# ── Config ────────────────────────────────────────────────────────────────────
OUT_DIR="./out"
PLAIN_BIN="${OUT_DIR}/plaintext.bin"    # raw binary
PLAIN_HEX="${OUT_DIR}/plaintext.hex"    # hex string
PLAIN_TXT="${OUT_DIR}/plaintext.txt"    # xxd dump
SHA256_HEX="${OUT_DIR}/sha256.hex"      # SHA-256 digest
SHA512_HEX="${OUT_DIR}/sha512.hex"      # SHA-512 digest
HASH_FILE="${OUT_DIR}/hashes.txt"       # combined summary

echo -e "${BOLD}SHA Hash Demo${RESET}  |  plaintext=${PLAINTEXT_BYTES} bytes"

# =============================================================================
# 1. Install OpenSSL
# =============================================================================
section "Step 1: Install OpenSSL"

SUDO=""; [[ "$(id -u)" != "0" ]] && command -v sudo &>/dev/null && SUDO="sudo"

if command -v openssl &>/dev/null; then
    ok "openssl already installed: $(openssl version)"
else
    info "Installing openssl..."
    if command -v apt-get &>/dev/null; then
        ${SUDO} apt-get update -qq
        ${SUDO} apt-get install -y openssl xxd
    elif command -v dnf &>/dev/null; then
        ${SUDO} dnf install -y openssl
    elif command -v yum &>/dev/null; then
        ${SUDO} yum install -y openssl
    elif command -v brew &>/dev/null; then
        brew install openssl
    else
        err "Unsupported package manager. Install openssl manually."
        exit 1
    fi
    ok "openssl installed: $(openssl version)"
fi

if ! command -v xxd &>/dev/null; then
    info "Installing xxd..."
    if command -v apt-get &>/dev/null; then
        ${SUDO} apt-get install -y xxd -qq
    fi
fi

# =============================================================================
# 2. Prepare output directory
# =============================================================================
section "Step 2: Prepare output directory"
mkdir -p "${OUT_DIR}"
ok "Output directory: ${OUT_DIR}/"

# =============================================================================
# 3. Generate random plaintext — .bin  .hex  .txt
# =============================================================================
section "Step 3: Generate random plaintext (${PLAINTEXT_BYTES} bytes)"

# 3a. Raw binary
openssl rand "${PLAINTEXT_BYTES}" > "${PLAIN_BIN}"

# 3b. Hex string — continuous lowercase hex, no spaces or newlines
xxd -p "${PLAIN_BIN}" | tr -d '\n' > "${PLAIN_HEX}"

# 3c. xxd annotated dump — offset | hex columns | ASCII sidebar
{
    echo "# Random plaintext -- ${PLAINTEXT_BYTES} bytes"
    echo "# Generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo ""
    xxd "${PLAIN_BIN}"
} > "${PLAIN_TXT}"

ok "plaintext.bin  ->  ${PLAIN_BIN}"
ok "plaintext.hex  ->  ${PLAIN_HEX}"
ok "plaintext.txt  ->  ${PLAIN_TXT}"
echo ""
echo -e "  ${YELLOW}$(cat "${PLAIN_HEX}")${RESET}"

# =============================================================================
# 4. Compute SHA hash sums — each saved to its own .hex file
# =============================================================================
section "Step 4: Compute SHA hash sums"

SHA256_HASH=$(openssl dgst -sha256 "${PLAIN_BIN}" | awk '{print $2}')
SHA512_HASH=$(openssl dgst -sha512 "${PLAIN_BIN}" | awk '{print $2}')

# Individual .hex files — just the bare digest string
echo -n "${SHA256_HASH}" > "${SHA256_HEX}"
echo -n "${SHA512_HASH}" > "${SHA512_HEX}"

# Combined summary file
{
    echo "# SHA hash sums of: ${PLAIN_BIN}"
    echo "# File size:        ${PLAINTEXT_BYTES} bytes"
    echo "# Generated:        $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo ""
    printf "SHA-256  (256-bit):  %s\n" "${SHA256_HASH}"
    printf "SHA-512  (512-bit):  %s\n" "${SHA512_HASH}"
} > "${HASH_FILE}"

ok "sha256.hex  ->  ${SHA256_HEX}"
ok "sha512.hex  ->  ${SHA512_HEX}"
ok "hashes.txt  ->  ${HASH_FILE}"
echo ""
printf "  ${MAGENTA}SHA-256  ${RESET}(256-bit)\n  %s\n\n" "${SHA256_HASH}"
printf "  ${MAGENTA}SHA-512  ${RESET}(512-bit)\n  %s\n"   "${SHA512_HASH}"

# =============================================================================
# 5. Verify — re-compute and compare against saved .hex files
# =============================================================================
section "Step 5: Verify -- re-compute and compare"

fail=0

check_hash() {
    local algo="$1" file="$2" saved_hex="$3"
    local recomputed
    recomputed=$(openssl dgst "-${algo}" "${PLAIN_BIN}" | awk '{print $2}')
    local saved
    saved=$(cat "${saved_hex}")
    if [[ "${recomputed}" == "${saved}" ]]; then
        ok "${algo} verified  (matches ${saved_hex})"
    else
        err "${algo} mismatch!"
        err "  expected : ${saved}"
        err "  got      : ${recomputed}"
        fail=1
    fi
}

check_hash "sha256" "${PLAIN_BIN}" "${SHA256_HEX}"
check_hash "sha512" "${PLAIN_BIN}" "${SHA512_HEX}"

(( fail )) && exit 1

# =============================================================================
# 6. Summary
# =============================================================================
section "Summary"
echo -e "  ${BOLD}File${RESET}                        ${BOLD}Contents${RESET}"
echo    "  ─────────────────────────────────────────────────────────────"
printf  "  %-28s  %s\n" "${PLAIN_BIN}"  "raw random binary (${PLAINTEXT_BYTES} bytes)"
printf  "  %-28s  %s\n" "${PLAIN_HEX}"  "plaintext as hex string"
printf  "  %-28s  %s\n" "${PLAIN_TXT}"  "xxd annotated dump"
printf  "  %-28s  %s\n" "${SHA256_HEX}" "SHA-256 (256-bit) digest"
printf  "  %-28s  %s\n" "${SHA512_HEX}" "SHA-512 (512-bit) digest"
printf  "  %-28s  %s\n" "${HASH_FILE}"  "all three digests combined"
echo ""
echo -e "  ${BOLD}Algorithm   Digest size   Hash${RESET}"
echo    "  ─────────────────────────────────────────────────────────────────────────────────────"
printf  "  SHA-256     256-bit       %s\n" "${SHA256_HASH}"
printf  "  SHA-512     512-bit       %s\n" "${SHA512_HASH}"
echo ""
ok "Done. Output files in ${OUT_DIR}/"