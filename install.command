#!/bin/bash
# ============================================================
# Mac-Arabic123-Fix Installer (Interactive Terminal UI)
# Developed by Muhammad El-Shaikh
# GitHub:  github.com/ElShaikh1945
# Email:   Muhammad.Al-Shaikh@outlook.com
# Copyright © 2026 Muhammad El-Shaikh. All rights reserved.
# ============================================================

# Get the directory where the double-clicked script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Automatically remove quarantine attributes from all project files
xattr -cr "$SCRIPT_DIR" 2>/dev/null || true

# Define colors using tput for portable and clean terminal formatting
RED=$(tput setaf 1 2>/dev/null || printf "")
GREEN=$(tput setaf 2 2>/dev/null || printf "")
YELLOW=$(tput setaf 3 2>/dev/null || printf "")
BLUE=$(tput setaf 4 2>/dev/null || printf "")
CYAN=$(tput setaf 6 2>/dev/null || printf "")
WHITE=$(tput setaf 7 2>/dev/null || printf "")
BOLD=$(tput bold 2>/dev/null || printf "")
NC=$(tput sgr0 2>/dev/null || printf "")
BG_BLUE=$(tput setab 4 2>/dev/null || printf "")

# Define RTL control characters for clean Arabic BiDi rendering in terminals
RLE=$(printf '\342\200\253')
PDF=$(printf '\342\200\254')
# LRO (Left-to-Right Override) forces the terminal to render characters exactly as written
LRO=$(printf '\342\200\255')

# ==============================
# Interactive Menu Functions
# ==============================

# Single-choice interactive menu with blue highlight
# Usage: choose_menu "prompt" "option1" "option2" ...
# Returns selected index (0-based) in variable MENU_RESULT
choose_menu() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=0
    local total=${#options[@]}
    local hint_text=""

    if [ "$INSTALL_LANG" = "en" ]; then
        hint_text="(Use ↑/↓ arrow keys to navigate and press Enter)"
    else
        hint_text="(استخدم أسهم ↑/↓ للتنقل ثم اضغط Enter)"
    fi

    # Hide cursor
    tput civis 2>/dev/null

    # Print prompt ONCE before redraw loop
    echo "${CYAN}${BOLD}${prompt}${NC}"

    while true; do
        # Move cursor up to redraw options + hint (except first draw)
        if [ -n "$_menu_drawn" ]; then
            tput cuu $((total + 1)) 2>/dev/null
        fi
        _menu_drawn=1

        # Print options
        for i in "${!options[@]}"; do
            tput el 2>/dev/null
            if [ $i -eq $selected ]; then
                echo "  ${BG_BLUE}${WHITE}${BOLD} ❯ ${options[$i]} ${NC}"
            else
                echo "    ${options[$i]}  "
            fi
        done

        # Print hint
        tput el 2>/dev/null
        echo "  ${BLUE}${hint_text}${NC}"

        # Read single keypress
        IFS= read -rsn1 key

        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 key
            case "$key" in
                '[A') # Up arrow
                    ((selected > 0)) && ((selected--))
                    ;;
                '[B') # Down arrow
                    ((selected < total - 1)) && ((selected++))
                    ;;
            esac
        elif [[ "$key" == "" ]]; then
            # Enter pressed
            break
        elif [[ "$key" == "1" && $total -ge 1 ]]; then
            selected=0; break
        elif [[ "$key" == "2" && $total -ge 2 ]]; then
            selected=1; break
        fi
    done

    # Show cursor
    tput cnorm 2>/dev/null
    unset _menu_drawn
    MENU_RESULT=$selected
}

# Multi-select checklist menu
# Usage: choose_multiselect "prompt" "option1" "option2" ...
# Returns space-separated indices of selected items in MULTI_RESULT
choose_multiselect() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=0
    local total=${#options[@]}
    local checked=()
    local hint_text=""

    # Initialize all as unchecked
    for ((i=0; i<total; i++)); do
        checked[$i]=0
    done

    if [ "$INSTALL_LANG" = "en" ]; then
        hint_text="(↑/↓ to navigate, Space to toggle, Enter to confirm)"
    else
        hint_text="(↑/↓ للتنقل، مسافة للتحديد/الإلغاء، Enter للتأكيد)"
    fi

    # Hide cursor
    tput civis 2>/dev/null

    # Print prompt ONCE before redraw loop
    echo "${CYAN}${BOLD}${prompt}${NC}"

    while true; do
        # Move cursor up to redraw options + hint (except first draw)
        if [ -n "$_multi_drawn" ]; then
            tput cuu $((total + 1)) 2>/dev/null
        fi
        _multi_drawn=1

        # Print options with checkboxes
        for i in "${!options[@]}"; do
            local mark="[ ]"
            if [ "${checked[$i]}" -eq 1 ]; then
                mark="[✓]"
            fi

            tput el 2>/dev/null
            if [ $i -eq $selected ]; then
                echo "  ${BG_BLUE}${WHITE}${BOLD} ❯ ${mark} ${options[$i]} ${NC}"
            else
                echo "    ${mark} ${options[$i]}  "
            fi
        done

        # Print hint
        tput el 2>/dev/null
        echo "  ${BLUE}${hint_text}${NC}"

        # Read single keypress
        IFS= read -rsn1 key

        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 key
            case "$key" in
                '[A') # Up arrow
                    ((selected > 0)) && ((selected--))
                    ;;
                '[B') # Down arrow
                    ((selected < total - 1)) && ((selected++))
                    ;;
            esac
        elif [[ "$key" == " " ]]; then
            # Space: toggle selection
            if [ "${checked[$selected]}" -eq 0 ]; then
                checked[$selected]=1
            else
                checked[$selected]=0
            fi
        elif [[ "$key" == "" ]]; then
            # Enter pressed
            break
        fi
    done

    # Show cursor
    tput cnorm 2>/dev/null
    unset _multi_drawn

    # Build result
    MULTI_RESULT=""
    for i in "${!checked[@]}"; do
        if [ "${checked[$i]}" -eq 1 ]; then
            MULTI_RESULT="$MULTI_RESULT $i"
        fi
    done
    MULTI_RESULT=$(echo "$MULTI_RESULT" | xargs)
}

# ==============================
# Main Script
# ==============================

# Full terminal reset: clears screen AND scrollback to remove "Last login" and empty space
printf '\033c'

# Developer Info Header
echo "${CYAN}${BOLD}==========================================================${NC}"
echo "${CYAN}${BOLD}               Mac-Arabic123-Fix Installer                ${NC}"
echo "${BLUE}  Developer: Muhammad El-Shaikh                           ${NC}"
echo "${BLUE}  GitHub:    github.com/ElShaikh1945                      ${NC}"
echo "${BLUE}  E-Mail:    Muhammad.Al-Shaikh@outlook.com               ${NC}"
echo "${BLUE}  Version:   1.0.1 (July 2026)                            ${NC}"
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
echo "${RLE}يدعم الأرقام القياسية في الصف العلوي ولوحة الأرقام الجانبية (Numpad) معاً.${PDF}"
echo ""
echo "${BOLD}English:${NC}"
echo "This installer configures a modified Arabic PC keyboard layout to type standard digits (123) instead of (١٢٣)."
echo "Supports standard digits on both the top row and the Numpad."
echo "----------------------------------------------------------"
echo ""

# 3. Language selection using interactive menu
choose_menu "${RLE}اختر لغة التثبيت / Select Installer Language:${PDF}" \
    "${RLE}العربية (الافتراضية) / Arabic (Default)${PDF}" \
    "English"

export INSTALL_LANG="ar"
if [ "$MENU_RESULT" -eq 1 ]; then
    export INSTALL_LANG="en"
fi
echo ""

# 4. Installation scope selection using interactive menu
if [ "$INSTALL_LANG" = "ar" ]; then
    choose_menu "${RLE}اختر نوع التثبيت:${PDF}" \
        "${RLE}تثبيت شخصي (الافتراضي، لحسابك فقط، بدون كلمة مرور)${PDF}" \
        "${RLE}تثبيت للنظام بالكامل (لكل المستخدمين وشاشة القفل، يتطلب كلمة مرور)${PDF}"
else
    choose_menu "Select Installation Type:" \
        "Personal installation (Default, current user only, no password required)" \
        "System-wide installation (all users & login screen, requires password)"
fi
SCOPE_CHOICE=$MENU_RESULT
echo ""

# ==============================
# Pre-Installation: Check Existing Keyboard Layout
# ==============================
EXISTING_FOUND=0
if [ -d "$HOME/Library/Keyboard Layouts/Arabic - 123 - PC.bundle" ] || \
   [ -f "$HOME/Library/Keyboard Layouts/Arabic - PC - 123.keylayout" ] || \
   [ -d "/Library/Keyboard Layouts/Arabic - 123 - PC.bundle" ] || \
   [ -f "/Library/Keyboard Layouts/Arabic - PC - 123.keylayout" ]; then
    EXISTING_FOUND=1
fi

if [ "$EXISTING_FOUND" -eq 0 ]; then
    if [ -x "$SCRIPT_DIR/enable_layout" ]; then
        if "$SCRIPT_DIR/enable_layout" --check-installed >/dev/null 2>&1; then
            EXISTING_FOUND=1
        fi
    fi
    if [ "$EXISTING_FOUND" -eq 0 ] && command -v xcrun >/dev/null 2>&1 && xcrun --find swift >/dev/null 2>&1; then
        if xcrun swift "$SCRIPT_DIR/enable_layout.swift" --check-installed >/dev/null 2>&1; then
            EXISTING_FOUND=1
        fi
    fi
fi

if [ "$EXISTING_FOUND" -eq 1 ]; then
    echo "${YELLOW}${BOLD}==========================================================${NC}"
    if [ "$INSTALL_LANG" = "ar" ]; then
        echo "${YELLOW}${BOLD}${RLE}تنبيه: تم العثور على لوحة مفاتيح مثبتة مسبقاً بنفس الاسم (Arabic - 123 - PC)${PDF}${NC}"
        echo "${YELLOW}${BOLD}==========================================================${NC}"
        echo "${RLE}لتفادي وجود لوحات مكررة في شريط اللغات وإعدادات النظام:${PDF}"
        echo "${RLE}سيقوم المثبت باستبدال النسخة القديمة بالكامل وتحديثها بنظافة.${PDF}"
        echo ""
        choose_menu "${RLE}هل ترغب في استبدال وتحديث اللوحة القديمة؟${PDF}" \
            "${RLE}نعم، استبدال وتحديث اللوحة القديمة (Overwrite & Update)${PDF}" \
            "${RLE}إلغاء التثبيت (الاحتفاظ بالإصدار الحالي دون تعديل)${PDF}"
    else
        echo "${YELLOW}${BOLD}Notice: A keyboard layout named 'Arabic - 123 - PC' is already installed.${NC}"
        echo "${YELLOW}${BOLD}==========================================================${NC}"
        echo "To prevent duplicate keyboards in the input menu and System Settings:"
        echo "The installer will cleanly overwrite and replace the old version."
        echo ""
        choose_menu "Do you want to overwrite and update the existing layout?" \
            "Yes, overwrite and update (Clean Replace)" \
            "Cancel installation (Keep existing version unchanged)"
    fi

    if [ "$MENU_RESULT" -eq 1 ]; then
        echo ""
        if [ "$INSTALL_LANG" = "ar" ]; then
            echo "${BLUE}${RLE}تم إلغاء التثبيت بناءً على طلبك. لم يتم إجراء أي تعديل.${PDF}${NC}"
            echo "${RLE}اضغط على [Enter] للخروج...${PDF}"
        else
            echo "${BLUE}Installation cancelled by user. No changes were made.${NC}"
            echo "Press [Enter] to exit..."
        fi
        read -r
        exit 0
    fi
    echo ""
fi
export OVERWRITE_CONFIRMED=1

# ==============================
# Installation
# ==============================
if [ "$SCOPE_CHOICE" -eq 1 ]; then
    # System-wide installation
    if [ "$INSTALL_LANG" = "ar" ]; then
        echo "${YELLOW}${BOLD}==========================================================${NC}"
        echo "${YELLOW}${BOLD}${RLE}جاري التثبيت لكامل النظام (يتطلب كلمة مرور المسؤول)${PDF}${NC}"
        echo "${YELLOW}${BOLD}==========================================================${NC}"
        echo "${RLE}يرجى إدخال كلمة مرور الماك الخاصة بك أدناه.${PDF}"
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
        if [ "$INSTALL_LANG" = "ar" ]; then
            echo "${RED}${BOLD}${RLE}خطأ في التثبيت للنظام بالكامل${PDF}${NC}"
            echo "${RED}${BOLD}==========================================================${NC}"
            echo "${RLE}السبب المحتمل:${PDF}"
            echo "${RLE}- إدخال كلمة مرور خاطئة أو إلغاء إدخالها.${PDF}"
            echo "${RLE}- وجود قيود حماية تمنع الكتابة في مجلد النظام الرئيسي.${PDF}"
            echo ""
            echo "${RLE}البديل الآمن:${PDF}"
            echo "${RLE}التثبيت الشخصي لا يتطلب كلمة مرور ويقوم بتثبيت اللوحة لحسابك فقط.${PDF}"
        else
            echo "${RED}${BOLD}System-wide Installation Failed${NC}"
            echo "${RED}${BOLD}==========================================================${NC}"
            echo "Possible cause:"
            echo "- Incorrect or cancelled administrator password."
            echo "- System write restrictions on the main /Library directory."
            echo ""
            echo "Safe Alternative:"
            echo "Personal installation requires no password and installs for your account only."
        fi
        echo "=========================================================="

        # Offer fallback to personal installation
        if [ "$INSTALL_LANG" = "ar" ]; then
            choose_menu "${RLE}هل تريد محاولة التثبيت الشخصي البديل؟${PDF}" \
                "${RLE}نعم، قم بالتثبيت الشخصي${PDF}" \
                "${RLE}لا، إلغاء${PDF}"
        else
            choose_menu "Try personal installation instead?" \
                "Yes, install for current user" \
                "No, cancel"
        fi

        if [ "$MENU_RESULT" -eq 0 ]; then
            echo ""
            if [ "$INSTALL_LANG" = "ar" ]; then
                echo "${RLE}جاري تشغيل التثبيت الشخصي...${PDF}"
            else
                echo "Running personal installation..."
            fi
            echo "----------------------------------------------------------"
            INSTALL_LANG="$INSTALL_LANG" bash install.sh
        else
            echo ""
            if [ "$INSTALL_LANG" = "ar" ]; then
                echo "${RLE}تم إلغاء التثبيت.${PDF}"
            else
                echo "Installation cancelled."
            fi
        fi
    fi
else
    # Personal/User-level installation (Default)
    INSTALL_LANG="$INSTALL_LANG" bash install.sh
fi

# ==============================
# Post-Installation: Testing Guide
# ==============================
if [ -z "$_INSTALL_FAILED" ]; then
    echo ""
    echo "${CYAN}${BOLD}==========================================================${NC}"
    if [ "$INSTALL_LANG" = "ar" ]; then
        echo "${CYAN}${BOLD}${RLE}               دليل تجربة واختبار اللوحة                ${PDF}${NC}"
        echo "${CYAN}${BOLD}==========================================================${NC}"
        echo "${RLE}يرجى تجربة اللوحة في أي تطبيق نصوص (مثل Notes أو متصفح):${PDF}"
        echo ""
        echo "${RLE}1. اختبار الأرقام (الصف العلوي والـ Numpad):${PDF}"
        echo "${RLE}   اكتب: 1234567890 ➔ تأكد أنها قياسية (123) وليست (١٢٣).${PDF}"
        echo ""
        echo "${RLE}2. اختبار أزرار الـ PC الرئيسية:${PDF}"
        echo "${RLE}   - مفتاح [ذ]: أعلى اليسار بجانب رقم 1.${PDF}"
        echo "${RLE}   - الحروف: ( ط - ك - د - ج - ح - خ ).${PDF}"
        echo ""
        echo "${RLE}3. نص تجريبي مقترح للكتابة والاختبار:${PDF}"
        echo "${YELLOW}${BOLD}${RLE}   \"اختبار لوحة المفاتيح 2026: رقم 123 - ذ ط ك - 100%\"${PDF}${NC}"
    else
        echo "${CYAN}${BOLD}             Keyboard Layout Verification Guide           ${NC}"
        echo "${CYAN}${BOLD}==========================================================${NC}"
        echo "Please test the layout in any text editor (e.g. Notes or Browser):"
        echo ""
        echo "1. Test Digits (Top Row & Numpad):"
        echo "   Type: 1234567890 ➔ Confirm standard digits (123) instead of (١٢٣)."
        echo ""
        echo "2. Test Key Arabic PC Buttons:"
        echo "   - Key [ذ]: Top-left next to number key 1."
        echo "   - Letters: ( ط - ك - د - ج - ح - خ )."
        echo ""
        echo "3. Suggested Sample Test Phrase:"
        echo "${YELLOW}${BOLD}   \"Keyboard Test 2026: No. 123 - ذ ط ك - 100%\"${NC}"
    fi
    echo "${CYAN}${BOLD}==========================================================${NC}"
    echo ""

    # ==============================
    # Post-Installation: Old Keyboard Cleanup
    # ==============================
    ARABIC_LAYOUTS=""
    if [ -x "$SCRIPT_DIR/enable_layout" ]; then
        ARABIC_LAYOUTS=$("$SCRIPT_DIR/enable_layout" --list-arabic 2>/dev/null || true)
    fi
    if [ -z "$ARABIC_LAYOUTS" ] && command -v xcrun >/dev/null 2>&1 && xcrun --find swift >/dev/null 2>&1; then
        ARABIC_LAYOUTS=$(xcrun swift "$SCRIPT_DIR/enable_layout.swift" --list-arabic 2>/dev/null || true)
    fi

    if [ -n "$ARABIC_LAYOUTS" ]; then
        # Parse layout names and IDs
        LAYOUT_IDS=()
        LAYOUT_NAMES=()
        while IFS='|' read -r lid lname; do
            [ -z "$lid" ] && continue
            LAYOUT_IDS+=("$lid")
            LAYOUT_NAMES+=("$lname")
        done <<< "$ARABIC_LAYOUTS"

        if [ ${#LAYOUT_NAMES[@]} -gt 0 ]; then
            echo ""
            if [ "$INSTALL_LANG" = "ar" ]; then
                choose_multiselect "${RLE}اختر لوحات المفاتيح العربية التي تريد إزالتها:${PDF}" "${LAYOUT_NAMES[@]}"
            else
                choose_multiselect "Select Arabic keyboard layouts to remove:" "${LAYOUT_NAMES[@]}"
            fi

            if [ -n "$MULTI_RESULT" ]; then
                # Build comma-separated list of IDs to disable
                IDS_TO_DISABLE=""
                for idx in $MULTI_RESULT; do
                    if [ -n "$IDS_TO_DISABLE" ]; then
                        IDS_TO_DISABLE="$IDS_TO_DISABLE,${LAYOUT_IDS[$idx]}"
                    else
                        IDS_TO_DISABLE="${LAYOUT_IDS[$idx]}"
                    fi
                done

                # Disable selected layouts
                DISABLE_RESULT=""
                if [ -x "$SCRIPT_DIR/enable_layout" ]; then
                    DISABLE_RESULT=$("$SCRIPT_DIR/enable_layout" --disable-ids "$IDS_TO_DISABLE" 2>/dev/null || true)
                fi
                if [ -z "$DISABLE_RESULT" ] && command -v xcrun >/dev/null 2>&1 && xcrun --find swift >/dev/null 2>&1; then
                    DISABLE_RESULT=$(xcrun swift "$SCRIPT_DIR/enable_layout.swift" --disable-ids "$IDS_TO_DISABLE" 2>/dev/null || true)
                fi
                echo "$DISABLE_RESULT"
                echo ""

                if [ "$INSTALL_LANG" = "ar" ]; then
                    echo "${GREEN}${BOLD}${RLE}تمت إزالة اللوحات المحددة بنجاح!${PDF}${NC}"
                else
                    echo "${GREEN}${BOLD}Selected layouts have been removed successfully!${NC}"
                fi
            else
                echo ""
                if [ "$INSTALL_LANG" = "ar" ]; then
                    echo "${RLE}لم يتم اختيار أي لوحة للحذف. تم الإبقاء على جميع اللوحات دون تغيير.${PDF}"
                else
                    echo "No layouts selected for removal. All existing layouts remain unchanged."
                fi
            fi
        fi
    fi
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
