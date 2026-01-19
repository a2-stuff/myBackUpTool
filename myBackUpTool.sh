#!/bin/bash

# ==============================================================================
# myBackUpTool v1.0.8 - Futuristic Backup Utility
# ==============================================================================

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
CONFIG_FILE="${HOME}/.myBackUpTool.conf"
SETTINGS_FILE="${HOME}/.myBackUpTool.settings"
LOG_FILE="${HOME}/myBackUpTool.log"
TEMP_DIR="/tmp"
THEME_FILE="/tmp/myBackUpTool_theme.rc"

# Default defaults
DEFAULT_REMOTE="gdrive:myBackUpTool_Data"
DEFAULT_THEME="matrix"
DEFAULT_IGNORES="*/node_modules/* */.next/*"
VERSION="v1.2.2"

# Create config files
if [ ! -f "$CONFIG_FILE" ]; then touch "$CONFIG_FILE"; fi

save_setting() {
    local key="$1"
    local val="$2"
    if [ -f "$SETTINGS_FILE" ]; then
        grep -v "^${key}=" "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp"
        mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
    fi
    echo "${key}=${val}" >> "$SETTINGS_FILE"
}

read_setting() {
    local key="$1"
    local default="$2"
    if [ -f "$SETTINGS_FILE" ]; then
        local val=$(grep "^${key}=" "$SETTINGS_FILE" | cut -d'=' -f2-)
        if [ -n "$val" ]; then echo "$val"; return; fi
    fi
    echo "$default"
}

CURRENT_REMOTE=$(read_setting "REMOTE" "$DEFAULT_REMOTE")
CURRENT_THEME=$(read_setting "THEME" "$DEFAULT_THEME")

# ------------------------------------------------------------------------------
# Graceful Exit
# ------------------------------------------------------------------------------
cleanup_and_exit() {
    pkill -P $$ 2>/dev/null
    rm -f "${TEMP_DIR}"/backup_*.zip
    rm -f "${TEMP_DIR}"/job_*.log
    
    local reset="\033[0m"
    local color="\033[0;32m"
    [ "$CURRENT_THEME" == "retro" ] && color="\033[0;33m"
    [ "$CURRENT_THEME" == "dracula" ] && color="\033[0;35m"
    [ "$CURRENT_THEME" == "oceanic" ] && color="\033[0;36m"
    
    clear
    echo -e "${color}"
    echo "----------------------------------------"
    echo " SYSTEM HALTED EXECUTION "
    echo "----------------------------------------"
    echo " Backup aborted by user."
    echo -e "${reset}"
    exit 130
}
trap cleanup_and_exit INT

# ------------------------------------------------------------------------------
# Theme Setup
# ------------------------------------------------------------------------------
setup_theme() {
    local theme_name=$(read_setting "THEME" "matrix")
    
    # Defaults
    local screen="(GREEN,BLACK,ON)"
    local dialog="(GREEN,BLACK,OFF)"
    local title="(GREEN,BLACK,ON)"
    local border="(GREEN,BLACK,ON)"
    local button_act="(BLACK,GREEN,OFF)"
    local button_inact="(GREEN,BLACK,OFF)"

    case $theme_name in
        retro) # Amber/Black
            screen="(YELLOW,BLACK,ON)"
            dialog="(YELLOW,BLACK,OFF)"
            title="(YELLOW,BLACK,ON)"
            border="(YELLOW,BLACK,ON)"
            button_act="(BLACK,YELLOW,OFF)"
            button_inact="(YELLOW,BLACK,OFF)"
            ;;
        dracula) # Purple/DarkGray (Simulated with Mag/Black for safety)
            screen="(MAGENTA,BLACK,ON)"
            dialog="(WHITE,BLACK,OFF)"
            title="(MAGENTA,BLACK,ON)"
            border="(MAGENTA,BLACK,ON)"
            button_act="(WHITE,MAGENTA,OFF)"
            button_inact="(MAGENTA,BLACK,OFF)"
            ;;
        oceanic) # Cyan/Blue
            screen="(CYAN,BLUE,ON)"
            dialog="(WHITE,BLUE,OFF)"
            title="(CYAN,BLUE,ON)"
            border="(CYAN,BLUE,ON)"
            button_act="(BLUE,CYAN,OFF)"
            button_inact="(CYAN,BLUE,OFF)"
            ;;
        cyberpunk)
            screen="(MAGENTA,BLACK,ON)"
            dialog="(CYAN,BLACK,OFF)"
            title="(MAGENTA,BLACK,ON)"
            border="(CYAN,BLACK,ON)"
            button_act="(BLACK,MAGENTA,OFF)"
            button_inact="(CYAN,BLACK,OFF)"
            ;;
        classic)
            screen="(WHITE,BLUE,ON)"
            dialog="(BLACK,WHITE,OFF)"
            title="(BLUE,WHITE,ON)"
            border="(BLUE,WHITE,ON)"
            button_act="(WHITE,RED,OFF)"
            button_inact="(BLACK,WHITE,OFF)"
            ;;
        *) ;;
    esac

    cat > "$THEME_FILE" <<EOF
aspect = 0
separate_widget = ""
tab_len = 0
visit_items = OFF
use_shadow = OFF
use_colors = ON
screen_color = $screen
shadow_color = (BLACK,BLACK,OFF)
dialog_color = $dialog
title_color = $title
border_color = $border
button_active_color = $button_act
button_inactive_color = $button_inact
button_key_active_color = $button_act
button_key_inactive_color = $button_inact
button_label_active_color = $button_act
button_label_inactive_color = $button_inact
inputbox_color = $dialog
inputbox_border_color = $border
searchbox_color = $dialog
searchbox_title_color = $title
searchbox_border_color = $border
position_indicator_color = $title
menubox_color = $dialog
menubox_border_color = $border
item_color = $dialog
item_selected_color = $button_act
tag_color = $title
tag_selected_color = $button_act
tag_key_color = $title
tag_key_selected_color = $button_act
check_color = $dialog
check_selected_color = $button_act
uarrow_color = $title
darrow_color = $title
itemhelp_color = $dialog
form_active_text_color = $button_act
form_text_color = $dialog
form_item_readonly_color = $dialog
gauge_color = $title
border2_color = $border
inputbox_border2_color = $border
searchbox_border2_color = $border
menubox_border2_color = $border
EOF
    export DIALOGRC="$THEME_FILE"
}

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
check_dependencies() {
    for cmd in dialog zip rclone; do
        if ! command -v $cmd &> /dev/null; then echo "Error: Missing $cmd"; exit 1; fi
    done
}

log_message() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# ------------------------------------------------------------------------------
# Settings
# ------------------------------------------------------------------------------
manage_ignores() {
    while true; do
        local cur=$(read_setting "IGNORES" "$DEFAULT_IGNORES")
        local cmd=$(dialog --title "Expert Ignore Manager" --menu "Current: $cur\n\nOperation:" 18 70 6 \
            "ADD_CUSTOM" "Add Manual Pattern" "ADD_COMMON" "Add Presets" "REMOVE" "Remove Patterns" "BACK" "Back" 3>&1 1>&2 2>&3)
        case $cmd in
            ADD_CUSTOM)
                local new=$(dialog --inputbox "Pattern:" 8 60 3>&1 1>&2 2>&3)
                [ -n "$new" ] && save_setting "IGNORES" "$cur $new"
                ;;
            ADD_COMMON)
                local presets=("*/node_modules/*" "Node" "off" "*/.git/*" "Git" "off" "*/.next/*" "NextJS" "off" "*/dist/*" "Dist" "off" "*.log" "Logs" "off")
                local sel=$(dialog --checklist "Select:" 20 60 10 "${presets[@]}" 3>&1 1>&2 2>&3)
                if [ -n "$sel" ]; then
                    eval "adds=($sel)"
                    for i in "${adds[@]}"; do [[ " $cur " != *" $i "* ]] && cur="$cur $i"; done
                    save_setting "IGNORES" "$cur"
                fi
                ;;
            REMOVE)
                local items=(); for i in $cur; do items+=("$i" "" "off"); done
                [ ${#items[@]} -eq 0 ] && continue
                local rem=$(dialog --checklist "Remove:" 20 60 10 "${items[@]}" 3>&1 1>&2 2>&3)
                if [ -n "$rem" ]; then
                    eval "dels=($rem)"
                    local new_l=""
                    for i in $cur; do
                        local keep=true; for d in "${dels[@]}"; do [ "$i" == "$d" ] && keep=false; done
                        [ "$keep" == "true" ] && new_l="$new_l $i"
                    done
                    save_setting "IGNORES" "$(echo $new_l | xargs)"
                fi
                ;;
            BACK) return ;;
            *) ;;
        esac
    done
}

settings_menu() {
    while true; do
        local th=$(read_setting "THEME" "matrix")
        local rem=$(read_setting "REMOTE" "$DEFAULT_REMOTE")
        local cmd=$(dialog --title "Configuration" --menu "Settings:" 18 60 7 "THEME" "[$th]" "REMOTE" "[$rem]" "IGNORES" "Manage Ignores" "CLOUD_SETUP" "Setup Cloud Access" "BACK" "Back" 3>&1 1>&2 2>&3)
        case $cmd in
            THEME)
                local n=$(dialog --menu "Theme:" 15 40 6 "matrix" "Matrix" "retro" "Retro (Amber)" "cyberpunk" "Cyberpunk" "dracula" "Dracula" "oceanic" "Oceanic" "classic" "Classic" 3>&1 1>&2 2>&3)
                [ -n "$n" ] && save_setting "THEME" "$n" && CURRENT_THEME="$n" && setup_theme
                ;;
            REMOTE)
                if [ -n "$rlist" ]; then
                    local options=()
                    while read -r line; do options+=("$line" "Remote"); done <<< "$rlist"
                    options+=("MANUAL" "Enter Path Manually")
                    local sel=$(dialog --menu "Select Cloud Provider:" 15 50 6 "${options[@]}" 3>&1 1>&2 2>&3)
                    if [ "$sel" == "MANUAL" ]; then
                        local n=$(dialog --inputbox "Remote Path (e.g. gdrive:Backup):" 8 60 "$rem" 3>&1 1>&2 2>&3)
                        [ -n "$n" ] && save_setting "REMOTE" "$n" && CURRENT_REMOTE="$n"
                    elif [ -n "$sel" ]; then
                         # Configure Folder
                         local folder=$(read_setting "REMOTE_FOLDER" "myBackUpTool_Data")
                         local new_f=$(dialog --inputbox "Folder on ${sel%:} (Default: $folder):" 8 60 "$folder" 3>&1 1>&2 2>&3)
                         [ -z "$new_f" ] && new_f="$folder"
                         save_setting "REMOTE_FOLDER" "$new_f"
                         
                         local n="${sel}${new_f}"
                         save_setting "REMOTE" "$n" && CURRENT_REMOTE="$n"
                    fi
                else
                    local n=$(dialog --inputbox "No Remotes Found. Enter Path:" 8 60 "$rem" 3>&1 1>&2 2>&3)
                    [ -n "$n" ] && save_setting "REMOTE" "$n" && CURRENT_REMOTE="$n"
                fi
                ;;
            IGNORES) manage_ignores ;;
            CLOUD_SETUP)
                clear
                echo "---------------------------------------------------------"
                echo " SYSTEM: Launching Cloud Configuration Wizard (rclone)   "
                echo "---------------------------------------------------------"
                echo "Follow instructions to add 'gdrive' or other remotes."
                echo "Press ENTER to begin..."
                read
                rclone config
                dialog --msgbox "Configuration wizard completed." 6 40
                ;;
            BACK) return ;;
            *) ;;
        esac
    done
}

info_section() {
    local r=$(read_setting "REMOTE" "$DEFAULT_REMOTE")
    local t=$(read_setting "THEME" "matrix")
    local v="$VERSION"
    dialog --title "About" --msgbox "myBackUpTool $v\n\nCreated By: not_jarod\nSource: https://github.com/a2-stuff/myBackUpTool\n\nTheme: $t\nRemote: $r\n\nFeatures: Multi-threaded, Exclusion Manager, Matrix UI." 15 65
}

# ------------------------------------------------------------------------------
# Directory Manager
# ------------------------------------------------------------------------------
manage_directories() {
    # Simplified for brevity in v1.0.8, functionality same
    while true; do
        local opts=(); local i=1
        while read l; do [ -n "$l" ] && opts+=("$i" "$l") && ((i++)); done < "$CONFIG_FILE"
        local cmd=$(dialog --menu "Targets:" 15 60 6 "ADD" "Add" "REMOVE" "Remove" "BACK" "Back" "${opts[@]}" 3>&1 1>&2 2>&3)
        case $cmd in
            ADD)
                local r=$(dialog --title "Select Root Directory" --dselect "$HOME/" 10 60 3>&1 1>&2 2>&3)
                if [ -d "$r" ]; then
                    local s=(); while read d; do [ "$d" != "$r" ] && s+=("$d" "" "off"); done < <(find "$r" -maxdepth 1 -type d 2>/dev/null)
                    local a=$(dialog --checklist "Add:" 20 60 10 "${s[@]}" 3>&1 1>&2 2>&3)
                    if [ -n "$a" ]; then eval "p=($a)"; for x in "${p[@]}"; do grep -qFx "$x" "$CONFIG_FILE" || echo "$x" >> "$CONFIG_FILE"; done; fi
                fi
                ;;
            REMOVE)
                 local opts=(); while read l; do [ -n "$l" ] && opts+=("$l" "" "off"); done < "$CONFIG_FILE"
                 [ ${#opts[@]} -gt 0 ] && local r=$(dialog --checklist "Remove:" 15 60 8 "${opts[@]}" 3>&1 1>&2 2>&3)
                 if [ -n "$r" ]; then
                     mv "$CONFIG_FILE" "${CONFIG_FILE}.bak"
                     touch "$CONFIG_FILE"
                     eval "d=($r)"
                     while read l; do
                         k=true; for x in "${d[@]}"; do [ "$x" == "$l" ] && k=false; done; [ "$k" == true ] && echo "$l" >> "$CONFIG_FILE"
                     done < "${CONFIG_FILE}.bak"; rm "${CONFIG_FILE}.bak"
                 fi
                 ;;
            BACK) return ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# Backup Logic (Advanced UI)
# ------------------------------------------------------------------------------
perform_backup() {
    local mode=$1
    local dest=$(read_setting "REMOTE" "$DEFAULT_REMOTE")
    local ig=$(read_setting "IGNORES" "$DEFAULT_IGNORES")
    set -f # Disable globbing for pattern split
    local args=(); for p in $ig; do args+=("-x" "$p"); done
    set +f
    local targets=()

    if [ "$mode" == "interactive" ]; then
        local opts=(); while read l; do [ -n "$l" ] && opts+=("$l" "" "on"); done < "$CONFIG_FILE"
        [ ${#opts[@]} -eq 0 ] && dialog --msgbox "No targets." 6 40 && return
        local s=$(dialog --checklist "Backup:" 15 60 8 "${opts[@]}" 3>&1 1>&2 2>&3)
        [ $? -ne 0 ] && return
        eval "targets=($s)"
    else
        while read l; do [ -n "$l" ] && targets+=("$l"); done < "$CONFIG_FILE"
    fi

    [ ${#targets[@]} -eq 0 ] && return
    
    local total=${#targets[@]}
    local counter=0
    local step_size=$((100 / total)) # approximate

    for src in "${targets[@]}"; do
        ((counter++))
        local pct=$(( (counter - 1) * 100 / total ))
        local dirn=$(basename "$src")
        local ts=$(date "+%Y-%m-%d_%H%M%S")
        local zn="backup_${dirn}_${ts}.zip"
        local zp="${TEMP_DIR}/${zn}"
        local job_log="${TEMP_DIR}/job_current.log"
        : > "$job_log"

        if [ "$mode" == "interactive" ]; then
            # v1.2.2 Unified Dashboard: Single Gauge with Streaming Logs
            : > "$job_log"
            touch "${TEMP_DIR}/progress.flag"
            
            # 1. Start Worker in Background (writes to log)
            (
                echo "[$(date +%T)] Init: Batch $counter of $total" >> "$job_log"
                parent_dir=$(dirname "$src")
                base_name=$(basename "$src")
                
                echo "[$(date +%T)] Compressing $base_name..." >> "$job_log"
                if (cd "$parent_dir" && zip -r -v "$zp" "$base_name" "${args[@]}" >> "$job_log" 2>&1); then
                    echo "[$(date +%T)] Uploading to $dest..." >> "$job_log"
                    if rclone copy -v "$zp" "$dest" >> "$job_log" 2>&1; then
                         rm -f "$zp"
                         echo "[$(date +%T)] Success: $dirn" >> "$job_log"
                         echo "SUCCESS" > "${TEMP_DIR}/status.flag"
                    else
                         echo "[$(date +%T)] Upload FAILED" >> "$job_log"
                         echo "FAIL" > "${TEMP_DIR}/status.flag"
                    fi
                else
                    echo "[$(date +%T)] Zip FAILED" >> "$job_log"
                    echo "FAIL" > "${TEMP_DIR}/status.flag"
                fi
                rm -f "${TEMP_DIR}/progress.flag"
            ) &
            bg_pid=$!
            
            # 2. Main Loop: Feed Gauge with Log Tail
            # We simulate progress % based on time or stages if we can't get real numbers
            # or just pulse. Let's do a pulse visual.
            local p=0
            while [ -f "${TEMP_DIR}/progress.flag" ]; do
                # Get last 15 lines of log
                local logs=$(tail -n 15 "$job_log")
                
                # Update Gauge
                echo "XXX"
                echo "$p"
                echo "$logs"
                echo "XXX"
                
                # Pulse effect
                p=$(( (p + 5) % 100 ))
                sleep 0.5
            done | dialog --title "Processing: $dirn ($counter/$total)" --gauge "Initializing..." 20 80 0

            wait $bg_pid
            
            if [ "$(cat "${TEMP_DIR}/status.flag" 2>/dev/null)" == "SUCCESS" ]; then
                log_message "Success: $dirn"
            else
                log_message "Failure: $dirn"
                dialog --msgbox "Error processing $dirn. Check logs." 6 40
            fi
            
            rm -f "${TEMP_DIR}/status.flag"
        else
            # Auto (Quiet)
             parent_dir=$(dirname "$src")
             base_name=$(basename "$src")
             (cd "$parent_dir" && zip -r -q "$zp" "$base_name" "${args[@]}") && rclone copy "$zp" "$dest" && rm -f "$zp"
        fi
        
        # Increment percentage
        pct=$(( counter * 100 / total ))
    done

    [ "$mode" == "interactive" ] && dialog --msgbox "Sequence Complete." 6 40
}

schedule_backup() {
    local t=$(dialog --inputbox "Time:" 8 40 "03:00" 3>&1 1>&2 2>&3)
    [ -n "$t" ] && (crontab -l 2>/dev/null | grep -v "$0" ; echo "${t:3:2} ${t:0:2} * * * /bin/bash $(realpath "$0") --backup-all") | crontab -
    dialog --msgbox "Scheduled." 6 40
}
remove_schedule() {
    (crontab -l 2>/dev/null | grep -v "$0") | crontab -; dialog --msgbox "Removed." 6 40
}
view_logs() {
    tail -n 30 "$LOG_FILE" > "${TEMP_DIR}/lv"; dialog --textbox "${TEMP_DIR}/lv" 20 75; rm "${TEMP_DIR}/lv"
}

# ------------------------------------------------------------------------------
# Entry
# ------------------------------------------------------------------------------
check_dependencies
if [ "$1" == "--backup-all" ]; then
    perform_backup "automated"
    exit 0
fi
setup_theme

while true; do
    CHOICE=$(dialog --clear --backtitle "myBackUpTool $VERSION" --title "Main Menu" --menu "Select:" 17 60 7 \
    1 "Backup" 2 "Dirs" 3 "Settings" 4 "Schedule" 5 "Stop Sched" 6 "Logs" 7 "Info" 8 "Exit" 3>&1 1>&2 2>&3)
    case $CHOICE in
        1) perform_backup "interactive" ;; 2) manage_directories ;; 3) settings_menu ;; 4) schedule_backup ;;
        5) remove_schedule ;; 6) view_logs ;; 7) info_section ;; 8) clear; break ;; *) clear; break ;;
    esac
done
