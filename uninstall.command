#!/bin/bash
# ============================================================
# Mac-Arabic123-Fix Uninstaller (Interactive Terminal UI)
# Developed by Muhammad El-Shaikh
# GitHub:  github.com/ElShaikh1945
# Email:   Muhammad.Al-Shaikh@outlook.com
# Copyright © 2026 Muhammad El-Shaikh. All rights reserved.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Automatically remove quarantine attributes from the directory
xattr -cr "$SCRIPT_DIR" 2>/dev/null || true

# Define colors using tput
RED=$(tput setaf 1 2>/dev/null || printf "")
GREEN=$(tput setaf 2 2>/dev/null || printf "")
YELLOW=$(tput setaf 3 2>/dev/null || printf "")
BLUE=$(tput setaf 4 2>/dev/null || printf "")
CYAN=$(tput setaf 6 2>/dev/null || printf "")
WHITE=$(tput setaf 7 2>/dev/null || printf "")
BOLD=$(tput bold 2>/dev/null || printf "")
NC=$(tput sgr0 2>/dev/null || printf "")
BG_BLUE=$(tput setab 4 2>/dev/null || printf "")

# BiDi Control Characters
RLE=$(printf '\342\200\253')
PDF=$(printf '\342\200\254')

choose_menu() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=0
    local total=${#options[@]}
    local hint_text=""

    if [ "$UNINSTALL_LANG" = "en" ]; then
        hint_text="(Use ↑/↓ arrow keys to navigate and press Enter)"
    else
        hint_text="(استخدم أسهم ↑/↓ للتنقل ثم اضغط Enter)"
    fi

    tput civis 2>/dev/null
    echo "${CYAN}${BOLD}${prompt}${NC}"

    while true; do
        if [ -n "$_menu_drawn" ]; then
            tput cuu $((total + 1)) 2>/dev/null
        fi
        _menu_drawn=1

        for i in "${!options[@]}"; do
            tput el 2>/dev/null
            if [ $i -eq $selected ]; then
                echo "  ${BG_BLUE}${WHITE}${BOLD} ❯ ${options[$i]} ${NC}"
            else
                echo "    ${options[$i]}  "
            fi
        done

        tput el 2>/dev/null
        echo "  ${BLUE}${hint_text}${NC}"

        IFS= read -rsn1 key

        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 key
            case "$key" in
                '[A') ((selected > 0)) && ((selected--)) ;;
                '[B') ((selected < total - 1)) && ((selected++)) ;;
            esac
        elif [[ "$key" == "" ]]; then
            break
        elif [[ "$key" == "1" && $total -ge 1 ]]; then
            selected=0; break
        elif [[ "$key" == "2" && $total -ge 2 ]]; then
            selected=1; break
        fi
    done

    tput cnorm 2>/dev/null
    unset _menu_drawn
    MENU_RESULT=$selected
}

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

    if [ "$UNINSTALL_LANG" = "en" ]; then
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

# Reset screen
printf '\033c'

echo "${RED}${BOLD}==========================================================${NC}"
echo "${RED}${BOLD}              Mac-Arabic123-Fix Uninstaller               ${NC}"
echo "${BLUE}  Developer: Muhammad El-Shaikh                           ${NC}"
echo "${BLUE}  GitHub:    github.com/ElShaikh1945                      ${NC}"
echo "${BLUE}  E-Mail:    Muhammad.Al-Shaikh@outlook.com               ${NC}"
echo "${RED}${BOLD}==========================================================${NC}"
echo ""

# Language selection
choose_menu "${RLE}اختر لغة معالج الحذف / Select Language:${PDF}" \
    "${RLE}العربية (الافتراضية) / Arabic (Default)${PDF}" \
    "English"

UNINSTALL_LANG="ar"
if [ "$MENU_RESULT" -eq 1 ]; then
    UNINSTALL_LANG="en"
fi
echo ""

# Confirmation menu
if [ "$UNINSTALL_LANG" = "ar" ]; then
    choose_menu "${RLE}هل أنت متأكد من رغبتك في إلغاء تثبيت لوحة المفاتيح (Arabic - 123 - PC)؟${PDF}" \
        "${RLE}نعم، قم بإلغاء التثبيت وحذف كافة الملفات المرتبطة${PDF}" \
        "${RLE}إلغاء (الاحتفاظ باللوحة كما هي)${PDF}"
else
    choose_menu "Are you sure you want to completely uninstall 'Arabic - 123 - PC'?" \
        "Yes, completely uninstall and remove all files" \
        "Cancel (Keep keyboard layout installed)"
fi

if [ "$MENU_RESULT" -eq 1 ]; then
    echo ""
    if [ "$UNINSTALL_LANG" = "ar" ]; then
        echo "${BLUE}${RLE}تم إلغاء عملية الحذف. لم يتم إجراء أي تغيير.${PDF}${NC}"
        echo "${RLE}اضغط على [Enter] للخروج...${PDF}"
    else
        echo "${BLUE}Uninstallation cancelled. No changes were made.${NC}"
        echo "Press [Enter] to exit..."
    fi
    read -r
    exit 0
fi

# ==============================
# Alternative Arabic Layout Selection
# ==============================
ARABIC_LAYOUTS=""
if [ -x "$SCRIPT_DIR/enable_layout" ]; then
    ARABIC_LAYOUTS=$("$SCRIPT_DIR/enable_layout" --list-all-arabic 2>/dev/null || true)
fi
if [ -z "$ARABIC_LAYOUTS" ] && command -v xcrun >/dev/null 2>&1 && xcrun --find swift >/dev/null 2>&1; then
    ARABIC_LAYOUTS=$(xcrun swift "$SCRIPT_DIR/enable_layout.swift" --list-all-arabic 2>/dev/null || true)
fi

if [ -n "$ARABIC_LAYOUTS" ]; then
    RAW_IDS=()
    RAW_NAMES=()
    LAYOUT_IDS=()
    LAYOUT_NAMES=()
    while IFS='|' read -r lid lname lstatus; do
        [ -z "$lid" ] && continue
        RAW_IDS+=("$lid")
        RAW_NAMES+=("$lname")
    done <<< "$ARABIC_LAYOUTS"

    # Prioritize Arabic - PC and standard Arabic at the top of the list
    for i in "${!RAW_IDS[@]}"; do
        if [ "${RAW_IDS[$i]}" = "com.apple.keylayout.ArabicPC" ]; then
            LAYOUT_IDS+=("${RAW_IDS[$i]}")
            LAYOUT_NAMES+=("${RAW_NAMES[$i]}")
            unset "RAW_IDS[i]"
            unset "RAW_NAMES[i]"
            break
        fi
    done
    for i in "${!RAW_IDS[@]}"; do
        if [ "${RAW_IDS[$i]}" = "com.apple.keylayout.Arabic" ]; then
            LAYOUT_IDS+=("${RAW_IDS[$i]}")
            LAYOUT_NAMES+=("${RAW_NAMES[$i]}")
            unset "RAW_IDS[i]"
            unset "RAW_NAMES[i]"
            break
        fi
    done
    for i in "${!RAW_IDS[@]}"; do
        LAYOUT_IDS+=("${RAW_IDS[$i]}")
        LAYOUT_NAMES+=("${RAW_NAMES[$i]}")
    done

    if [ ${#LAYOUT_NAMES[@]} -gt 0 ]; then
        echo ""
        echo "${CYAN}${BOLD}==========================================================${NC}"
        if [ "$UNINSTALL_LANG" = "ar" ]; then
            echo "${CYAN}${BOLD}${RLE}          اختيار لوحة مفاتيح عربية بديلة (اختياري)          ${PDF}${NC}"
            echo "${CYAN}${BOLD}==========================================================${NC}"
            echo "${RLE}قبل إتمام الحذف، يمكنك اختيار لوحة مفاتيح عربية من لوحات الماك${PDF}"
            echo "${RLE}لتفعيلها تلقائياً لتكون جاهزة للاستخدام بدلاً من اللوحة الحالية:${PDF}"
            echo ""
            choose_multiselect "${RLE}اختر لوحة المفاتيح العربية البديلة التي ترغب في تفعيلها:${PDF}" "${LAYOUT_NAMES[@]}"
        else
            echo "${CYAN}${BOLD}       Select Alternative Arabic Keyboard (Optional)      ${NC}"
            echo "${CYAN}${BOLD}==========================================================${NC}"
            echo "Before completing uninstallation, you can select an Arabic"
            echo "keyboard layout to automatically activate in its place:"
            echo ""
            choose_multiselect "Select alternative Arabic keyboard layout(s) to activate:" "${LAYOUT_NAMES[@]}"
        fi

        if [ -n "$MULTI_RESULT" ]; then
            echo ""
            if [ "$UNINSTALL_LANG" = "ar" ]; then
                echo "${CYAN}${BOLD}${RLE}جاري تفعيل اللوحة/اللوحات البديلة المحددة...${PDF}${NC}"
            else
                echo "${CYAN}${BOLD}Activating selected alternative layout(s)...${NC}"
            fi

            for idx in $MULTI_RESULT; do
                local_tid="${LAYOUT_IDS[$idx]}"
                local_tname="${LAYOUT_NAMES[$idx]}"
                if [ -x "$SCRIPT_DIR/enable_layout" ]; then
                    "$SCRIPT_DIR/enable_layout" --enable-id "$local_tid" >/dev/null 2>&1 || true
                elif command -v xcrun >/dev/null 2>&1 && xcrun --find swift >/dev/null 2>&1; then
                    xcrun swift "$SCRIPT_DIR/enable_layout.swift" --enable-id "$local_tid" >/dev/null 2>&1 || true
                fi
                if [ "$UNINSTALL_LANG" = "ar" ]; then
                    echo "  ${GREEN}✓${NC} ${RLE}تم تفعيل:${PDF} ${BOLD}${local_tname}${NC}"
                else
                    echo "  ${GREEN}✓${NC} Activated: ${BOLD}${local_tname}${NC}"
                fi
            done
        else
            echo ""
            if [ "$UNINSTALL_LANG" = "ar" ]; then
                echo "${BLUE}${RLE}لم يتم اختيار أي لوحة بديلة. سيتم إكمال الحذف فقط.${PDF}${NC}"
            else
                echo "${BLUE}No alternative layout selected. Proceeding with uninstallation only.${NC}"
            fi
        fi
    fi
fi

echo ""
if [ "$UNINSTALL_LANG" = "ar" ]; then
    echo "${CYAN}${BOLD}${RLE}جاري إلغاء تثبيت لوحة المفاتيح وتنظيف النظام...${PDF}${NC}"
else
    echo "${CYAN}${BOLD}Uninstalling keyboard layout and cleaning system...${NC}"
fi
echo "----------------------------------------------------------"

TARGET_IDS="org.sil.ukelele.keyboardlayout.arabic123pc.arabic-123-pc,org.sil.ukelele.keyboardlayout.arabic123pc.keylayout.Arabic-123-PC"

# 1. Disable input source from macOS
if [ -x "$SCRIPT_DIR/enable_layout" ]; then
    "$SCRIPT_DIR/enable_layout" --disable-ids "$TARGET_IDS" >/dev/null 2>&1 || true
elif command -v xcrun >/dev/null 2>&1 && xcrun --find swift >/dev/null 2>&1; then
    xcrun swift "$SCRIPT_DIR/enable_layout.swift" --disable-ids "$TARGET_IDS" >/dev/null 2>&1 || true
fi

# 2. Remove user-level layout files
rm -rf "$HOME/Library/Keyboard Layouts/Arabic - 123 - PC.bundle" 2>/dev/null || true
rm -rf "$HOME/Library/Keyboard Layouts/Arabic - PC - 123.keylayout" 2>/dev/null || true

# 3. Check and remove system-wide files if they exist
if [ -d "/Library/Keyboard Layouts/Arabic - 123 - PC.bundle" ] || [ -f "/Library/Keyboard Layouts/Arabic - PC - 123.keylayout" ]; then
    echo ""
    if [ "$UNINSTALL_LANG" = "ar" ]; then
        echo "${YELLOW}${RLE}تم العثور على ملفات اللوحة في مجلد النظام الشامل.${PDF}${NC}"
        echo "${YELLOW}${RLE}يرجى إدخال كلمة مرور الماك لحذفها من مجلد النظام:${PDF}${NC}"
    else
        echo "${YELLOW}System-wide layout files detected.${NC}"
        echo "${YELLOW}Please enter your Mac password to remove them from /Library:${NC}"
    fi
    sudo rm -rf "/Library/Keyboard Layouts/Arabic - 123 - PC.bundle" 2>/dev/null || true
    sudo rm -rf "/Library/Keyboard Layouts/Arabic - PC - 123.keylayout" 2>/dev/null || true
fi

# 4. Refresh keyboard cache
touch "$HOME/Library/Keyboard Layouts" 2>/dev/null || true
killall -9 TextInputMenuAgent 2>/dev/null || true
killall -9 TextInputHost 2>/dev/null || true
killall -9 AppleSpell 2>/dev/null || true
sleep 1.5

echo ""
echo "${GREEN}${BOLD}==========================================================${NC}"
if [ "$UNINSTALL_LANG" = "ar" ]; then
    echo "${GREEN}${BOLD}${RLE}نجاح: تم إلغاء تثبيت لوحة المفاتيح وحذفها بنجاح!${PDF}${NC}"
    echo "${GREEN}${BOLD}----------------------------------------------------------${NC}"
    echo "${RLE}ملاحظة: إذا كانت اللوحة لا تزال تظهر في شريط القوائم، يرجى إعادة تشغيل الماك لتفريغ الذاكرة المؤقتة.${PDF}"
    echo ""
    echo "${BLUE}${RLE}يمكنك الآن إغلاق نافذة التيرمينال بأمان.${PDF}${NC}"
    echo "${RLE}اضغط على [Enter] للخروج...${PDF}"
else
    echo "${GREEN}${BOLD}Success: Keyboard layout uninstalled and removed successfully!${NC}"
    echo "${GREEN}${BOLD}----------------------------------------------------------${NC}"
    echo "Note: If the layout still appears in your menu bar, please restart your Mac to flush cache."
    echo ""
    echo "${BLUE}You can now safely close this Terminal window.${NC}"
    echo "Press [Enter] to exit..."
fi
echo "${GREEN}${BOLD}==========================================================${NC}"
read -r
exit 0
