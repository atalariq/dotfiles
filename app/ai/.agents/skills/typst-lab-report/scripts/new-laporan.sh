#!/usr/bin/env bash
# new-laporan.sh — scaffold folder laporan praktikum baru
# Usage: ./new-laporan.sh [nama-folder]
# Example: ./new-laporan.sh "pertemuan-4-stack-queue"
#
# Requires: TEMPLATE_DIR env var, or auto-detected from script location.
# Recommended: put this script at ~/.agents/skills/typst-lab-report/scripts/new-laporan.sh
# and set TEMPLATE_DIR=~/.agents/skills/typst-lab-report/template

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${TEMPLATE_DIR:-"$SCRIPT_DIR/../template"}"

# ── Colors ────────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { echo -e "${GREEN}✓${RESET} $*"; }
info() { echo -e "${CYAN}→${RESET} $*"; }
warn() { echo -e "${YELLOW}!${RESET} $*"; }
die()  { echo -e "${RED}✗ ERROR:${RESET} $*" >&2; exit 1; }

# ── Validate template ─────────────────────────────────────────────────────────

[[ -d "$TEMPLATE_DIR" ]] || die "Template dir not found: $TEMPLATE_DIR"
[[ -f "$TEMPLATE_DIR/report.typ" ]] || die "Template report.typ not found in $TEMPLATE_DIR"
[[ -f "$TEMPLATE_DIR/references.bib" ]] || die "Template references.bib not found in $TEMPLATE_DIR"

# ── Get folder name ───────────────────────────────────────────────────────────

if [[ $# -ge 1 ]]; then
    FOLDER_NAME="$1"
else
    echo -e "${BOLD}Nama folder laporan:${RESET}"
    echo -e "${CYAN}(contoh: pertemuan-4-stack-queue)${RESET}"
    read -r FOLDER_NAME
fi

[[ -n "$FOLDER_NAME" ]] || die "Nama folder tidak boleh kosong."
[[ -d "$FOLDER_NAME" ]] && die "Folder '$FOLDER_NAME' sudah ada."

# ── Interactive metadata ───────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}Isi metadata laporan (kosongkan jika belum tahu):${RESET}"
echo ""

prompt() {
    local label="$1"
    local var_name="$2"
    local default="${3:-}"
    local display_default=""
    [[ -n "$default" ]] && display_default=" [${default}]"
    read -r -p "  $label$display_default: " value
    printf '%s' "${value:-$default}"
}

META_AUTHOR=$(prompt "Nama lengkap" "author")
META_ID=$(prompt "NIM" "id")
META_CLASS=$(prompt "Kelas" "class")
META_COURSE=$(prompt "Nama matkul" "course")
META_COURSE_CODE=$(prompt "Kode matkul" "course_code")
META_LECTURER=$(prompt "Nama dosen" "lecturer")
META_MEETING=$(prompt "Pertemuan ke-" "meeting")
META_TITLE=$(prompt "Judul praktikum" "title")

# ── Scaffold ──────────────────────────────────────────────────────────────────

echo ""
info "Membuat folder: $FOLDER_NAME/"

mkdir -p "$FOLDER_NAME/assets"
mkdir -p "$FOLDER_NAME/src"

# Copy logo if exists
if [[ -f "$TEMPLATE_DIR/assets/logo.png" ]]; then
    cp "$TEMPLATE_DIR/assets/logo.png" "$FOLDER_NAME/assets/logo.png"
    ok "assets/logo.png"
else
    warn "logo.png tidak ditemukan di template, skip."
fi

# Copy references.bib
cp "$TEMPLATE_DIR/references.bib" "$FOLDER_NAME/references.bib"
ok "references.bib"

# Generate report.typ with metadata injected
YEAR=$(date +%Y)

sed \
    -e "s|author: \"…\"|author: \"${META_AUTHOR}\"|g" \
    -e "s|id: \"…\"|id: \"${META_ID}\"|g" \
    -e "s|class: \"…\"|class: \"${META_CLASS}\"|g" \
    -e "s|course: \"…\"|course: \"${META_COURSE}\"|g" \
    -e "s|course-code: \"…\"|course-code: \"${META_COURSE_CODE}\"|g" \
    -e "s|lecturer: \"…\"|lecturer: \"${META_LECTURER}\"|g" \
    -e "s|meeting: \"…\"|meeting: ${META_MEETING}|g" \
    -e "s|title: \"…\"|title: \"${META_TITLE}\"|g" \
    -e "s|year: [0-9]\{4\}|year: ${YEAR}|g" \
    "$TEMPLATE_DIR/report.typ" > "$FOLDER_NAME/report.typ"

ok "report.typ (metadata injected)"

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}Struktur yang dibuat:${RESET}"
find "$FOLDER_NAME" | sort | sed 's|[^/]*/|  |g'

echo ""
echo -e "${GREEN}${BOLD}Selesai!${RESET} Buka project dengan:"
echo ""
echo -e "  ${CYAN}cd $FOLDER_NAME && opencode${RESET}"
echo ""
echo -e "Lalu ketik: ${BOLD}\"mulai laporan\"${RESET} atau ${BOLD}\"quick, ini source code-nya: ...\"${RESET}"
