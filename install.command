#!/bin/bash
# Get the directory where the double-clicked script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

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
# LRO (Left-to-Right Override) forces the terminal to render characters exactly as written
LRO=$(printf '\342\200\255')

# Full terminal reset: clears screen AND scrollback to remove "Last login" and empty space
printf '\033c'

# Developer Info Header
echo "${CYAN}${BOLD}==========================================================${NC}"
echo "${CYAN}${BOLD}               Mac-Arabic123-Fix Installer                ${NC}"
echo "${BLUE}  Developer: Muhammad El-Shaikh                           ${NC}"
echo "${BLUE}  GitHub:    github.com/ElShaikh1945                      ${NC}"
echo "${BLUE}  E-Mail:    Muhammad.Al-Shaikh@outlook.com                      ${NC}"
echo "${BLUE}  Version:   1.0.0 (July 2026)                            ${NC}"
echo "${CYAN}${BOLD}==========================================================${NC}"
echo ""

# 1. Print ASCII keyboard layout (LRO-wrapped to prevent BiDi reordering of Arabic chars)
echo "${CYAN}${BOLD}${LRO} ┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───────┐${PDF}${NC}"
echo "${CYAN}${BOLD}${LRO} │ ذ │ 9 │ 8 │ 7 │ 6 │ 5 │ 4 │ 3 │ 2 │ 1 │ 0 │ - │ = │ Back  │${PDF}${NC}"
echo "${CYAN}${BOLD}${LRO} ├───┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─────┤${PDF}${NC}"
echo "${CYAN}${BOLD}${LRO} │  \  │ د │ ج │ ح │ خ │ ه │ ع │ غ │ ف │ ق │ ث │ ص │ ض │ Tab │${PDF}${NC}"
echo "${CYAN}${BOLD}${LRO} ├─────┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴─────┤${PDF}${NC}"
echo "${CYAN}${BOLD}${LRO} │ Caps │ ط │ ك │ م │ ن │ ت │ ا │ ل │ ب │ ي │ س │ ش │  Enter │${PDF}${NC}"
echo "${CYAN}${BOLD}${LRO} ├──────┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴────────┤${PDF}${NC}"
echo "${CYAN}${BOLD}${LRO} │  Shift │ ظ │ ز │ و │ ة │ ى │ لا │ ر │ ؤ │ ء │ ئ │   Shift  │${PDF}${NC}"
echo "${CYAN}${BOLD}${LRO} └────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴──────────┘${PDF}${NC}"
echo ""

# 2. Show brief, illustrative bilingual explanation
echo "${BOLD}${RLE}العربية:${PDF}${NC}"
echo "${RLE}هذا البرنامج يثبت لوحة مفاتيح عربي PC معدلة لتكتب الأرقام القياسية (123) بدلاً من الهندية (١٢٣).${PDF}"
echo "${RLE}سيقوم السكربت تلقائياً بنسخ الحزمة، ضبط صلاحيات النظام، وتفعيل لوحة المفاتيح.${PDF}"
echo ""
echo "${BOLD}English:${NC}"
echo "This installer configures a modified Arabic PC keyboard layout to type standard digits (123) instead of (١٢٣)."
echo "The script will automatically copy the layout bundle, fix file permissions, and activate it."
echo "----------------------------------------------------------"
echo ""

# 3. Prompt for language selection (wrapped in RTL to ensure alignment)
echo "${CYAN}${BOLD}${RLE}اختر لغة التثبيت / Select Installer Language:${PDF}${NC}"
echo "${RLE}1) العربية (الافتراضية) / Arabic (Default)${PDF}"
echo "2) English"
printf "${RLE}اختر / Choose (1-2): ${PDF}"
read -r LANG_CHOICE

export INSTALL_LANG="ar"
if [ "$LANG_CHOICE" = "2" ]; then
    export INSTALL_LANG="en"
fi
echo ""

# 4. Prompt for installation scope
if [ "$INSTALL_LANG" = "ar" ]; then
    echo "${CYAN}${BOLD}${RLE}اختر نوع التثبيت:${PDF}${NC}"
    echo "${RLE}1) تثبيت شخصي (الافتراضي، لحسابك الحالي فقط، ولا يتطلب كلمة مرور)${PDF}"
    echo "${RLE}2) تثبيت للنظام بالكامل (لكافة مستخدمي الجهاز وشاشة القفل، يتطلب كلمة المرور)${PDF}"
    printf "${RLE}اختر (1-2) [الافتراضي: 1]: ${PDF}"
    read -r SCOPE_CHOICE
else
    echo "${CYAN}${BOLD}Select Installation Type:${NC}"
    echo "1) Personal installation (Default, current user only, no password required)"
    echo "2) System-wide installation (all users & login screen, requires password)"
    printf "Choose (1-2) [Default: 1]: "
    read -r SCOPE_CHOICE
fi
echo ""

# Execute based on scope choice
if [ "$SCOPE_CHOICE" = "2" ]; then
    # System-wide installation
    if [ "$INSTALL_LANG" = "ar" ]; then
        echo "${YELLOW}${BOLD}==========================================================${NC}"
        echo "${YELLOW}${BOLD}${RLE}جاري التثبيت لكامل النظام (يتطلب كلمة مرور المسؤول)${PDF}${NC}"
        echo "${YELLOW}${BOLD}==========================================================${NC}"
        echo "${RLE}يرجى إدخال كلمة مرور الماك (الباسورد) الخاصة بك أدناه.${PDF}"
        echo "${BLUE}${BOLD}${RLE}ملاحظة:${PDF}${NC} ${RLE}لن تظهر أي أحرف أو نجوم على الشاشة أثناء كتابة كلمة المرور.${PDF}"
        echo "----------------------------------------------------------"
    else
        echo "${YELLOW}${BOLD}==========================================================${NC}"
        echo "${YELLOW}${BOLD}Installing system-wide (requires administrator password)${NC}"
        echo "${YELLOW}${BOLD}==========================================================${NC}"
        echo "Please enter your Mac password when prompted below."
        echo "${BLUE}${BOLD}Note:${NC} No characters will show on the screen while typing your password."
        echo "----------------------------------------------------------"
    fi

    # Run installer as root/sudo, passing the selected language
    if ! sudo INSTALL_LANG="$INSTALL_LANG" bash install.sh; then
        echo ""
        echo "${RED}${BOLD}==========================================================${NC}"
        echo "${RED}${BOLD}خطأ في التثبيت للنظام / System-wide Installation Failed${NC}"
        echo "${RED}${BOLD}==========================================================${NC}"
        if [ "$INSTALL_LANG" = "ar" ]; then
            echo "${RLE}السبب المحتمل:${PDF}"
            echo "${RLE}- إدخال كلمة مرور خاطئة أو إلغاء إدخالها.${PDF}"
            echo "${RLE}- وجود قيود حماية تمنع الكتابة في مجلد النظام الرئيسي.${PDF}"
            echo ""
            echo "${RLE}البديل الآمن:${PDF}"
            echo "${RLE}التثبيت الشخصي لا يتطلب كلمة مرور ويقوم بتثبيت اللوحة لحسابك فقط.${PDF}"
            echo "=========================================================="
            printf "${RLE}هل تريد محاولة التثبيت الشخصي البديل؟ (y/n) [y]: ${PDF}"
        else
            echo "Possible cause:"
            echo "- Incorrect or cancelled administrator password."
            echo "- System write restrictions on the main /Library directory."
            echo ""
            echo "Safe Alternative:"
            echo "Personal installation requires no password and installs for your account only."
            echo "=========================================================="
            printf "Try personal installation instead? (y/n) [y]: "
        fi
        read -r ANSWER

        if [[ -z "$ANSWER" || "$ANSWER" =~ ^[Yy]$ || "$ANSWER" = "1" || "$ANSWER" = "نعم" ]]; then
            echo ""
            if [ "$INSTALL_LANG" = "ar" ]; then
                echo "${RLE}جاري تشغيل التثبيت الشخصي... / Running personal installation...${PDF}"
            else
                echo "Running personal installation..."
            fi
            echo "----------------------------------------------------------"
            bash install.sh
        else
            echo ""
            if [ "$INSTALL_LANG" = "ar" ]; then
                echo "${RLE}تم إلغاء التثبيت الشخصي. / Personal installation cancelled.${PDF}"
            else
                echo "Personal installation cancelled."
            fi
        fi
    fi
else
    # Personal/User-level installation (Default)
    bash install.sh
fi

# Keep terminal open so user can read instructions/errors
echo ""
if [ "$INSTALL_LANG" = "ar" ]; then
    echo "${RLE}يمكنك إغلاق هذه النافذة الآن بأمان.${PDF}"
    echo "${RLE}اضغط على [Enter] للخروج...${PDF}"
else
    echo "You can now safely close this window."
    echo "Press [Enter] to exit..."
fi
read -r
