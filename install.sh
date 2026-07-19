#!/bin/bash
# Script to install the fixed Arabic keyboard layout on macOS
# Highly automated, with error handling, logging, and automatic cache reload attempts.

set -e # Exit immediately if a command exits with a non-zero status

# Get the script's directory path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/install_debug.log"

# Define colors using tput for portable and clean terminal formatting
RED=$(tput setaf 1 2>/dev/null || printf "")
GREEN=$(tput setaf 2 2>/dev/null || printf "")
YELLOW=$(tput setaf 3 2>/dev/null || printf "")
BLUE=$(tput setaf 4 2>/dev/null || printf "")
CYAN=$(tput setaf 6 2>/dev/null || printf "")
BOLD=$(tput bold 2>/dev/null || printf "")
NC=$(tput sgr0 2>/dev/null || printf "")

# Define RTL control characters for clean Arabic BiDi rendering in terminals
RLE=$(printf '\342\200\253')
PDF=$(printf '\342\200\254')

# ==============================
# Progress Bar & Spinner System
# ==============================
TOTAL_STEPS=6
CURRENT_STEP=0
BAR_WIDTH=30

# Spinner animation function - runs a brief visual spinner then prints final step
show_step() {
    local desc="$1"
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percent=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local filled=$((CURRENT_STEP * BAR_WIDTH / TOTAL_STEPS))
    local empty=$((BAR_WIDTH - filled))

    # Build the progress bar string
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    # Brief spinner animation (writes directly to /dev/tty to bypass tee buffering)
    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    if [ -t 1 ] && [ -c /dev/tty ] && [ -w /dev/tty ]; then
        for s in "${spin_chars[@]}"; do
            printf "\r  ${CYAN}%s${NC} [${GREEN}%s${NC}] ${BOLD}%3d%%${NC}  %s" "$s" "$bar" "$percent" "$desc" > /dev/tty
            sleep 0.06
        done
    fi

    # Print final completed line with checkmark (goes through tee to log file too)
    printf "\r  ${GREEN}✓${NC} [${GREEN}%s${NC}] ${BOLD}%3d%%${NC}  %s\n" "$bar" "$percent" "$desc"
}

# Clear old log file if it exists
rm -f "$LOG_FILE"

# Language selection (use exported INSTALL_LANG if already set by wrapper script, otherwise prompt)
if [ -z "$INSTALL_LANG" ]; then
    INSTALL_LANG="ar"

    # Prompt for language selection before redirecting stdout/stderr to avoid buffering
    echo "${CYAN}${BOLD}اختر لغة التثبيت / Select Installer Language:${NC}"
    echo "1) العربية (الافتراضية) / Arabic (Default)"
    echo "2) English"
    printf "اختر / Choose (1-2): "
    read -r LANG_CHOICE

    if [ "$LANG_CHOICE" = "2" ]; then
        INSTALL_LANG="en"
    fi
    echo ""
fi

# Redirect all subsequent output (stdout and stderr) to both the screen and the log file
exec > >(tee -i "$LOG_FILE") 2>&1

# Display header
if [ "$INSTALL_LANG" = "ar" ]; then
    echo "${CYAN}${BOLD}==========================================================${NC}"
    echo "${CYAN}${BOLD}             مُثبت لوحة مفاتيح Arabic-123-PC              ${NC}"
    echo "${BLUE}  ${RLE}تطوير: محمد الشيخ${PDF}                                      ${NC}"
    echo "${BLUE}  GitHub:  github.com/ElShaikh1945                        ${NC}"
    echo "${BLUE}  E-Mail:  Muhammad.Al-Shaikh@outlook.com                 ${NC}"
    echo "${CYAN}${BOLD}==========================================================${NC}"
else
    echo "${CYAN}${BOLD}==========================================================${NC}"
    echo "${CYAN}${BOLD}               Mac-Arabic123-Fix Installer                ${NC}"
    echo "${BLUE}  Developer: Muhammad El-Shaikh                           ${NC}"
    echo "${BLUE}  GitHub:    github.com/ElShaikh1945                      ${NC}"
    echo "${BLUE}  E-Mail:    Muhammad.Al-Shaikh@outlook.com               ${NC}"
    echo "${CYAN}${BOLD}==========================================================${NC}"
fi
echo ""

# Localized messages dictionary
if [ "$INSTALL_LANG" = "ar" ]; then
    MSG_NOTE="${RLE}ملاحظة:${PDF}"
    MSG_TIP="${RLE}نصيحة:${PDF}"
    MSG_ERROR="${RLE}خطأ:${PDF}"
    MSG_SUCCESS="${RLE}نجاح:${PDF}"
    MSG_RUN_USER="${RLE}جاري التشغيل كمستخدم عادي. سيتم التثبيت للمستخدم الحالي فقط.${PDF}"
    MSG_RUN_ROOT="${RLE}جاري التشغيل كمسؤول (root). سيتم التثبيت لكافة مستخدمي النظام.${PDF}"
    MSG_TIP_ROOT="${RLE}نصيحة: لتثبيت النظام بالكامل (موصى به لدعم شاشة تسجيل الدخول)، قم بتشغيل: sudo bash $0${PDF}"
    MSG_STEP_VERIFY="${RLE}التحقق من نظام التشغيل والملفات المصدرية${PDF}"
    MSG_STEP_CLEAN="${RLE}تنظيف ملفات التثبيت القديمة${PDF}"
    MSG_STEP_COPY="${RLE}نسخ حزمة لوحة المفاتيح${PDF}"
    MSG_STEP_PERM="${RLE}ضبط صلاحيات الملفات${PDF}"
    MSG_STEP_CACHE="${RLE}تحديث ذاكرة التخزين المؤقت${PDF}"
    MSG_STEP_ACTIVATE="${RLE}تفعيل لوحة المفاتيح في النظام${PDF}"
    MSG_NO_SWIFT="${RLE}تم تخطي التفعيل التلقائي (أداة swift غير متوفرة).${PDF}"
    MSG_NO_SWIFT_MANUAL="${RLE}يرجى تفعيل لوحة المفاتيح يدوياً من إعدادات النظام.${PDF}"
    MSG_SUCCESS_MSG="${RLE}تم تثبيت وتفعيل لوحة المفاتيح بنجاح!${PDF}"
    MSG_FALLBACK_NOTE="${RLE}ملاحظة: إذا لم تعمل لوحة المفاتيح فوراً أو لم تظهر في مصادر الإدخال:${PDF}"
    MSG_FALLBACK_1="${RLE}   1. يرجى إعادة تشغيل جهاز الماك لتفريغ ذاكرة التخزين المؤقت.${PDF}"
    MSG_FALLBACK_2="${RLE}   2. تأكد يدوياً من تفعيل 'Arabic - 123 - PC' من إعدادات النظام > لوحة المفاتيح > مصادر الإدخال.${PDF}"
    MSG_TERMINAL_CLOSE="${RLE}يمكنك الآن إغلاق نافذة التيرمينال بأمان.${PDF}"
    MSG_OS_ERROR="${RLE}خطأ: هذا السكربت مخصص لنظام macOS فقط.${PDF}"
    MSG_BUNDLE_ERROR="${RLE}خطأ: لم يتم العثور على الحزمة المصدرية في${PDF}"
    MSG_BUNDLE_ERROR_TIP="${RLE}يرجى التأكد من تشغيل السكربت من داخل مجلد المشروع.${PDF}"
else
    MSG_NOTE="Note:"
    MSG_TIP="Tip:"
    MSG_ERROR="Error:"
    MSG_SUCCESS="Success:"
    MSG_RUN_USER="Running as standard user. Installing for the current user only."
    MSG_RUN_ROOT="Running as root. Installing system-wide."
    MSG_TIP_ROOT="Tip: To install system-wide (recommended for login screen support), run: sudo bash $0"
    MSG_STEP_VERIFY="Verifying operating system and source files"
    MSG_STEP_CLEAN="Cleaning up old installation files"
    MSG_STEP_COPY="Copying keyboard layout bundle"
    MSG_STEP_PERM="Setting file permissions"
    MSG_STEP_CACHE="Refreshing system keyboard cache"
    MSG_STEP_ACTIVATE="Activating keyboard layout"
    MSG_NO_SWIFT="Auto-activation skipped (swift CLI not available)."
    MSG_NO_SWIFT_MANUAL="Please activate the keyboard layout manually in System Settings."
    MSG_SUCCESS_MSG="Keyboard layout installed and activated successfully!"
    MSG_FALLBACK_NOTE="Note: If the layout does not work immediately, or doesn't show up in your input sources:"
    MSG_FALLBACK_1="   1. Please restart your Mac to force cache clearance."
    MSG_FALLBACK_2="   2. Manually verify under System Settings > Keyboard > Input Sources that 'Arabic - 123 - PC' is added and active."
    MSG_TERMINAL_CLOSE="You can now safely close this Terminal window."
    MSG_OS_ERROR="Error: This script is only intended for macOS."
    MSG_BUNDLE_ERROR="Error: Source bundle not found at"
    MSG_BUNDLE_ERROR_TIP="Please make sure you are running the script from the project directory."
fi

# Error handler function
error_handler() {
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        echo ""
        if [ "$INSTALL_LANG" = "ar" ]; then
            echo "${RED}${BOLD}==========================================================${NC}"
            echo "${RED}${BOLD}${RLE}خطأ: حدث خطأ أثناء التثبيت (رمز الخطأ: $EXIT_CODE)${PDF}${NC}"
            echo "${RED}${BOLD}==========================================================${NC}"
            echo "${RLE}يرجى الإبلاغ عن هذه المشكلة عبر فتح تذكرة على GitHub:${PDF}"
            echo "https://github.com/ElShaikh1945/Mac-Arabic123-Fix/issues"
            echo ""
            echo "${RLE}يرجى إرفاق محتويات ملف سجل التشخيص:${PDF}"
            echo "${YELLOW}${RLE}مسار ملف السجل:${PDF}${NC} $LOG_FILE"
            echo "${RED}${BOLD}==========================================================${NC}"
        else
            echo "${RED}${BOLD}==========================================================${NC}"
            echo "${RED}${BOLD}ERROR: An error occurred during installation (Exit Code: $EXIT_CODE)${NC}"
            echo "${RED}${BOLD}==========================================================${NC}"
            echo "Please report this issue by creating a ticket on GitHub:"
            echo "https://github.com/ElShaikh1945/Mac-Arabic123-Fix/issues"
            echo ""
            echo "Attach the contents of the diagnostic log file:"
            echo "${YELLOW}Log File Location:${NC} $LOG_FILE"
            echo "${RED}${BOLD}==========================================================${NC}"
        fi
    fi
}

# Trap any error or exit to invoke the error handler
trap error_handler EXIT

# Determine destination directory
if [ "$EUID" -ne 0 ]; then
    echo "${BLUE}${BOLD}${MSG_NOTE}${NC} ${MSG_RUN_USER}"
    DEST_DIR="$HOME/Library/Keyboard Layouts"
else
    echo "${BLUE}${BOLD}${MSG_NOTE}${NC} ${MSG_RUN_ROOT}"
    DEST_DIR="/Library/Keyboard Layouts"
fi
echo ""

SOURCE_BUNDLE="$SCRIPT_DIR/Arabic - 123 - PC.bundle"

# ==============================
# Installation Steps with Progress Bar
# ==============================

# Step 1: Verify OS and source files
if [ "$(uname)" != "Darwin" ]; then
    echo "${RED}${BOLD}${MSG_OS_ERROR}${NC}"
    exit 1
fi
if [ ! -d "$SOURCE_BUNDLE" ]; then
    echo "${RED}${BOLD}${MSG_BUNDLE_ERROR} '$SOURCE_BUNDLE'.${NC}"
    echo "${MSG_BUNDLE_ERROR_TIP}"
    exit 1
fi
show_step "$MSG_STEP_VERIFY"

# Step 2: Clean old installation files
rm -rf "$HOME/Library/Keyboard Layouts/Arabic - PC - 123.keylayout"
rm -rf "$HOME/Library/Keyboard Layouts/Arabic - 123 - PC.bundle"
if [ "$EUID" -eq 0 ]; then
    rm -rf "/Library/Keyboard Layouts/Arabic - PC - 123.keylayout"
    rm -rf "/Library/Keyboard Layouts/Arabic - 123 - PC.bundle"
fi
show_step "$MSG_STEP_CLEAN"

# Step 3: Copy bundle to destination
mkdir -p "$DEST_DIR"
cp -R "$SOURCE_BUNDLE" "$DEST_DIR/"
if [ "$EUID" -eq 0 ]; then
    chown -R root:wheel "$DEST_DIR/Arabic - 123 - PC.bundle"
fi
show_step "$MSG_STEP_COPY"

# Step 4: Set permissions
chmod -R 755 "$DEST_DIR/Arabic - 123 - PC.bundle"
show_step "$MSG_STEP_PERM"

# Step 5: Refresh keyboard cache
touch "$DEST_DIR"
killall -9 TextInputMenuAgent 2>/dev/null || true
killall -9 TextInputHost 2>/dev/null || true
killall -9 AppleSpell 2>/dev/null || true
sleep 1.5
show_step "$MSG_STEP_CACHE"

# Step 6: Activate keyboard layout
if command -v xcrun >/dev/null 2>&1 && xcrun --find swift >/dev/null 2>&1; then
    if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
        sudo -u "$SUDO_USER" xcrun swift "$SCRIPT_DIR/enable_layout.swift" 2>>"$LOG_FILE" || true
    else
        xcrun swift "$SCRIPT_DIR/enable_layout.swift" 2>>"$LOG_FILE" || true
    fi
fi
show_step "$MSG_STEP_ACTIVATE"

echo ""
echo "${GREEN}${BOLD}==========================================================${NC}"
echo "${GREEN}${BOLD}${MSG_SUCCESS} ${MSG_SUCCESS_MSG}${NC}"
echo "${GREEN}${BOLD}----------------------------------------------------------${NC}"
echo "${YELLOW}${BOLD}${MSG_FALLBACK_NOTE}${NC}"
echo "${MSG_FALLBACK_1}"
echo "${MSG_FALLBACK_2}"
echo ""
echo "${BLUE}${MSG_TERMINAL_CLOSE}${NC}"
echo "${GREEN}${BOLD}==========================================================${NC}"
