#!/bin/bash
#===================================================================
#  DeelTech Solutions - Faculty Account Automation System
#===================================================================
#  Description : Automated user account creation tool for
#                TNTech CS Department faculty and staff.
#                Scrapes faculty data, creates Linux accounts,
#                and provides manual user management.
#
#  Course      : CSC2510 - DevOps Final Project (Spring 2026)
#  Author      : [Team Members]
#  Date        : April 2026
#  Version     : 1.0
#  Environment : Ubuntu 24.04 / BASH 5.2.21
#===================================================================

# ──────────────────────────────────────────────────────────────────
# ANSI Color Definitions
# ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
# shellcheck disable=SC2034
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ──────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────
FACULTY_URL="https://www.tntech.edu/engineering/programs/csc/faculty-and-staff.php"
LICENSE_DIR="/etc/deeltech"
LICENSE_FILE="${LICENSE_DIR}/.dtk_sys.dat"
PASSWORD_SUFFIX="DEELTECH"
CREATED_USERS_LOG="/var/log/deeltech_created_users.log"

# ──────────────────────────────────────────────────────────────────
# Utility Functions
# ──────────────────────────────────────────────────────────────────

# Print a styled banner
print_banner() {
    echo -e "${CYAN}"
    echo "  ╔════════════════════════════════════════════════════════════════════════╗"
    echo "  ║                                                                        ║"
    echo "  ║   ██████╗ ███████╗███████╗██╗  ████████╗███████╗ ██████╗██╗  ██╗       ║"
    echo "  ║   ██╔══██╗██╔════╝██╔════╝██║  ╚══██╔══╝██╔════╝██╔════╝██║  ██║       ║"
    echo "  ║   ██║  ██║█████╗  █████╗  ██║     ██║   █████╗  ██║     ███████║       ║"
    echo "  ║   ██║  ██║██╔══╝  ██╔══╝  ██║     ██║   ██╔══╝  ██║     ██╔══██║       ║"
    echo "  ║   ██████╔╝███████╗███████╗███████╗██║   ███████╗╚██████╗██║  ██║       ║"
    echo "  ║   ╚═════╝ ╚══════╝╚══════╝╚══════╝╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝       ║"
    echo "  ║                                                                        ║"
    echo "  ║              Faculty Account Automation System                          ║"
    echo "  ║                 DeelTech Solutions  v1.0                                ║"
    echo "  ║                                                                        ║"
    echo "  ╚════════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# Print a section header
print_header() {
    local title="$1"
    local width=58
    local pad=$(( (width - ${#title}) / 2 ))
    echo ""
    echo -e "${BLUE}  ┌──────────────────────────────────────────────────────────┐${RESET}"
    printf "${BLUE}  │${WHITE}%*s%s%*s${BLUE}│${RESET}\n" $pad "" "$title" $(( width - pad - ${#title} )) ""
    echo -e "${BLUE}  └──────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

# Print status messages
print_success() { echo -e "  ${GREEN}[✓]${RESET} $1"; }
print_error()   { echo -e "  ${RED}[✗]${RESET} $1"; }
print_info()    { echo -e "  ${YELLOW}[i]${RESET} $1"; }
print_warn()    { echo -e "  ${YELLOW}[!]${RESET} $1"; }

# Horizontal rule
print_hr() {
    echo -e "  ${DIM}──────────────────────────────────────────────────────────${RESET}"
}

# ──────────────────────────────────────────────────────────────────
# Part 4: Licensing System
# ──────────────────────────────────────────────────────────────────

# Reconstruct the valid license key using obfuscation.
# The key is split across multiple variables and encoded so it
# never appears as a single plaintext string in the source.
get_valid_key() {
    # Encoded segments (base64 chunks of the key, split and reordered)
    local seg_a seg_b seg_c seg_d seg_e
    seg_a=$(echo -n "NUE3" | base64 -d 2>/dev/null)     # 5A7
    seg_b=$(echo -n "QjlD" | base64 -d 2>/dev/null)     # B9C
    seg_c=$(echo -n "MUQz" | base64 -d 2>/dev/null)     # 1D3
    seg_d=$(echo -n "RTVG" | base64 -d 2>/dev/null)     # E5F
    seg_e=$(echo -n "N0c5SA==" | base64 -d 2>/dev/null) # 7G9H

    # Assemble the full key from decoded segments
    echo "${seg_a}${seg_b}${seg_c}${seg_d}${seg_e}"
}

# Check if a valid license exists; if not, prompt the user.
check_license() {
    print_header "License Verification"

    # If the license file already exists, verify its contents
    if [[ -f "$LICENSE_FILE" ]]; then
        local stored_hash
        stored_hash=$(cat "$LICENSE_FILE" 2>/dev/null)
        local valid_hash
        valid_hash=$(get_valid_key | sha256sum | awk '{print $1}')

        if [[ "$stored_hash" == "$valid_hash" ]]; then
            print_success "Valid license detected. Access granted."
            echo ""
            return 0
        else
            print_error "License file is corrupted or invalid."
            rm -f "$LICENSE_FILE" 2>/dev/null
        fi
    fi

    # No valid license file — prompt the user
    print_info "No valid license found on this system."
    echo ""
    echo -e "  ${WHITE}Please enter your 16-digit DeelTech license key.${RESET}"
    echo -e "  ${DIM}  (Format: XXXXXXXXXXXXXXXX)${RESET}"
    echo ""

    local attempts=3
    while (( attempts > 0 )); do
        echo -ne "  ${CYAN}License Key: ${RESET}"
        read -r user_key

        # Validate length
        if [[ ${#user_key} -ne 16 ]]; then
            (( attempts-- ))
            print_error "Key must be exactly 16 characters. ($attempts attempts remaining)"
            continue
        fi

        # Compare against the valid key
        local valid_key
        valid_key=$(get_valid_key)
        if [[ "$user_key" == "$valid_key" ]]; then
            # Store a hash of the key (not the key itself)
            mkdir -p "$LICENSE_DIR" 2>/dev/null
            echo "$user_key" | sha256sum | awk '{print $1}' > "$LICENSE_FILE"
            chmod 600 "$LICENSE_FILE"
            echo ""
            print_success "License activated successfully!"
            print_info "License file saved. You will not be prompted again."
            echo ""
            return 0
        else
            (( attempts-- ))
            print_error "Invalid license key. ($attempts attempts remaining)"
        fi
    done

    echo ""
    print_error "Too many failed attempts. Access denied."
    print_info "Contact DeelTech Solutions support for a valid license."
    echo ""
    exit 1
}

# ──────────────────────────────────────────────────────────────────
# Part 1: Web Scraper & Parser
# ──────────────────────────────────────────────────────────────────

# Check that curl or wget is available
check_download_tool() {
    if command -v curl &>/dev/null; then
        echo "curl"
    elif command -v wget &>/dev/null; then
        echo "wget"
    else
        print_error "Neither curl nor wget is installed." >&2
        print_info "Install one with: sudo apt install curl" >&2
        return 1
    fi
}

# Scrape the TNTech faculty page and return parsed names.
# Each line of output is: Firstname Lastname
scrape_faculty() {
    print_header "Scraping TNTech CS Faculty & Staff" >&2

    local tool
    tool=$(check_download_tool) || return 1

    print_info "Downloading faculty page..." >&2
    print_info "URL: ${FACULTY_URL}" >&2
    echo "" >&2

    local html
    if [[ "$tool" == "curl" ]]; then
        html=$(curl -sL "$FACULTY_URL" 2>/dev/null)
    else
        html=$(wget -qO- "$FACULTY_URL" 2>/dev/null)
    fi

    if [[ -z "$html" ]]; then
        print_error "Failed to download the faculty page." >&2
        print_info "Check your internet connection and try again." >&2
        return 1
    fi

    print_success "Page downloaded successfully." >&2
    print_info "Parsing faculty and staff names..." >&2
    echo "" >&2

    # Parse names from the HTML.
    # Faculty names appear in two patterns on this page:
    #   1. <h4><strong>Name, Ph.D.</strong></h4>  (most faculty)
    #      Variations include <br> inside, split <strong> tags, &nbsp;
    #   2. <h3>Name</h3>  (a few staff members like Jennifer Murphy)
    #
    # Strategy:
    #   1. Extract lines containing h4/strong or h3 name patterns
    #   2. Strip all HTML tags and entities
    #   3. Remove degree suffixes (Ph.D., etc.)
    #   4. Clean up whitespace

    local names

    # Extract h4+strong blocks: flatten multi-tag patterns into one line per entry
    # Also grab standalone h3 names (non-section-headers)
    names=$(echo "$html" \
        | grep -oP '<h4><strong>.*?</h4>|<h3>[A-Z][a-zA-Z]+ [A-Z][a-zA-Z]+</h3>' \
        | sed 's/<[^>]*>//g' \
        | sed 's/&nbsp;/ /g' \
        | sed 's/,[ ]*Ph\.D\.//g' \
        | sed 's/,[ ]*Ph\.D//g' \
        | sed 's/[ \t]*$//;s/^[ \t]*//' \
        | sed 's/  */ /g' \
        | sed '/^$/d' \
        | grep -P '^[A-Z]' \
        | grep -vP '^(Leadership|Professors|Associate|Assistant|Senior|Lecturers|Instructors|Adjunct|Emeritus|Advisors|Staff|Faculty)' \
    )

    echo "$names"
}

# Display parsed names in a formatted table
display_names() {
    local names="$1"
    local count=0

    print_hr
    printf "  ${BOLD}${WHITE}%-4s %-20s %-20s${RESET}\n" "#" "First Name" "Last Name"
    print_hr

    while IFS= read -r fullname; do
        [[ -z "$fullname" ]] && continue
        (( count++ ))

        local first last
        first=$(echo "$fullname" | awk '{print $1}')
        last=$(echo "$fullname" | awk '{print $NF}')

        printf "  ${CYAN}%-4s${RESET} %-20s %-20s\n" "$count" "$first" "$last"
    done <<< "$names"

    print_hr
    echo -e "  ${GREEN}Total: $count faculty/staff members found.${RESET}"
    echo ""

    return $count
}

# ──────────────────────────────────────────────────────────────────
# Part 2 & 3: User Account Creation
# ──────────────────────────────────────────────────────────────────

# Check if running as root (required for user creation)
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This operation requires root privileges."
        print_info "Please run: sudo $0"
        return 1
    fi
    return 0
}

# Create a single user account.
# Arguments: $1 = first name, $2 = last name
create_user() {
    local first="$1"
    local last="$2"

    # Validate names contain only safe characters (letters, hyphens, apostrophes)
    if [[ ! "$first" =~ ^[a-zA-Z\'-]+$ ]] || [[ ! "$last" =~ ^[a-zA-Z\'-]+$ ]]; then
        print_error "Invalid characters in name '${first} ${last}'. Only letters, hyphens, and apostrophes are allowed."
        return 1
    fi

    # Generate username: first.last (all lowercase)
    local username
    username=$(echo "${first}.${last}" | tr '[:upper:]' '[:lower:]')

    # Validate username length (Linux max is 32 characters)
    if [[ ${#username} -gt 32 ]]; then
        print_error "Generated username '${username}' exceeds 32-character limit."
        return 1
    fi

    # Generate password: firstnamelastnameDEELTECH (preserve original casing)
    local password="${first}${last}${PASSWORD_SUFFIX}"

    # Check if user already exists
    if id "$username" &>/dev/null; then
        print_warn "User '${username}' already exists. Skipping."
        return 2
    fi

    # Create the user account
    useradd -m -s /bin/bash "$username" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        print_error "Failed to create user '${username}'."
        return 1
    fi

    # Set the password
    echo "${username}:${password}" | chpasswd 2>/dev/null
    if [[ $? -ne 0 ]]; then
        print_error "Failed to set password for '${username}'."
        return 1
    fi

    # Log the creation
    echo "$(date '+%Y-%m-%d %H:%M:%S') | Created user: ${username} | Name: ${first} ${last}" >> "$CREATED_USERS_LOG"

    print_success "Created user: ${BOLD}${username}${RESET}  ${DIM}(password set)${RESET}"
    return 0
}

# Batch create users from a list of names.
# Input: newline-separated full names
batch_create_users() {
    local names="$1"

    check_root || return 1

    print_header "Creating User Accounts"

    local total=0 created=0 skipped=0 failed=0

    while IFS= read -r fullname; do
        [[ -z "$fullname" ]] && continue
        (( total++ ))

        # Extract first name (first word) and last name (last word)
        local first last
        first=$(echo "$fullname" | awk '{print $1}')
        last=$(echo "$fullname" | awk '{print $NF}')

        create_user "$first" "$last"
        case $? in
            0) (( created++ )) ;;
            2) (( skipped++ )) ;;
            *) (( failed++ )) ;;
        esac
    done <<< "$names"

    echo ""
    print_hr
    echo -e "  ${BOLD}${WHITE}Account Creation Summary${RESET}"
    print_hr
    echo -e "  ${WHITE}Total processed:${RESET}  $total"
    echo -e "  ${GREEN}Created:${RESET}          $created"
    echo -e "  ${YELLOW}Skipped (exist):${RESET}  $skipped"
    echo -e "  ${RED}Failed:${RESET}           $failed"
    print_hr
    echo ""
}

# ──────────────────────────────────────────────────────────────────
# Part 1 Combined: Scrape & Create
# ──────────────────────────────────────────────────────────────────
scrape_and_create() {
    local names
    names=$(scrape_faculty)

    if [[ -z "$names" ]]; then
        print_error "No names were parsed from the faculty page."
        return 1
    fi

    display_names "$names"

    echo -ne "  ${YELLOW}Proceed with user account creation? (y/n): ${RESET}"
    read -r confirm || confirm="n"
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        batch_create_users "$names"
    else
        print_info "Account creation cancelled."
    fi
}

# ──────────────────────────────────────────────────────────────────
# Part 3: Manual Add User
# ──────────────────────────────────────────────────────────────────
manual_add_user() {
    check_root || return 1

    print_header "Manual User Account Creation"

    echo -ne "  ${CYAN}Enter first name: ${RESET}"
    read -r first_name || { echo ""; print_info "End of input detected."; return 1; }
    echo -ne "  ${CYAN}Enter last name:  ${RESET}"
    read -r last_name || { echo ""; print_info "End of input detected."; return 1; }

    # Validate input
    if [[ -z "$first_name" || -z "$last_name" ]]; then
        print_error "Both first and last name are required."
        return 1
    fi

    # Remove leading/trailing whitespace
    first_name=$(echo "$first_name" | sed 's/^[ \t]*//;s/[ \t]*$//')
    last_name=$(echo "$last_name" | sed 's/^[ \t]*//;s/[ \t]*$//')

    # Validate names contain only safe characters
    if [[ ! "$first_name" =~ ^[a-zA-Z\'-]+$ ]]; then
        print_error "First name contains invalid characters. Only letters, hyphens, and apostrophes are allowed."
        return 1
    fi
    if [[ ! "$last_name" =~ ^[a-zA-Z\'-]+$ ]]; then
        print_error "Last name contains invalid characters. Only letters, hyphens, and apostrophes are allowed."
        return 1
    fi

    local username
    username=$(echo "${first_name}.${last_name}" | tr '[:upper:]' '[:lower:]')
    local password="${first_name}${last_name}${PASSWORD_SUFFIX}"

    echo ""
    echo -e "  ${WHITE}Username:${RESET} $username"
    echo -e "  ${WHITE}Password:${RESET} ${password}"
    echo ""
    echo -ne "  ${YELLOW}Create this user? (y/n): ${RESET}"
    read -r confirm || confirm="n"

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        create_user "$first_name" "$last_name"
    else
        print_info "User creation cancelled."
    fi
}

# ──────────────────────────────────────────────────────────────────
# View Created Users
# ──────────────────────────────────────────────────────────────────
view_created_users() {
    print_header "DeelTech Created User Accounts"

    if [[ ! -f "$CREATED_USERS_LOG" ]]; then
        print_info "No users have been created yet."
        print_info "Log file: ${CREATED_USERS_LOG}"
        echo ""
        return 0
    fi

    local count=0

    print_hr
    printf "  ${BOLD}${WHITE}%-22s %-20s %-25s${RESET}\n" "Date/Time" "Username" "Full Name"
    print_hr

    while IFS='|' read -r timestamp username fullname; do
        [[ -z "$timestamp" ]] && continue
        (( count++ ))

        # Trim whitespace from each field
        timestamp=$(echo "$timestamp" | sed 's/^[ \t]*//;s/[ \t]*$//')
        username=$(echo "$username" | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/^Created user: //')
        fullname=$(echo "$fullname" | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/^Name: //')

        printf "  ${DIM}%-22s${RESET} ${CYAN}%-20s${RESET} %-25s\n" "$timestamp" "$username" "$fullname"
    done < "$CREATED_USERS_LOG"

    print_hr
    echo -e "  ${GREEN}Total created users: $count${RESET}"
    echo ""
}

# ──────────────────────────────────────────────────────────────────
# Main Menu
# ──────────────────────────────────────────────────────────────────
show_menu() {
    echo ""
    echo -e "  ${BOLD}${WHITE}Main Menu${RESET}"
    print_hr
    echo -e "  ${CYAN}1)${RESET} Scrape Faculty & Create Users  ${DIM}(default)${RESET}"
    echo -e "  ${CYAN}2)${RESET} Add User Manually"
    echo -e "  ${CYAN}3)${RESET} View Created Users"
    echo -e "  ${CYAN}4)${RESET} Exit"
    print_hr
    echo ""
}

# ──────────────────────────────────────────────────────────────────
# Main Entry Point
# ──────────────────────────────────────────────────────────────────
main() {
    clear
    print_banner

    # Part 4: License check (must pass before anything else)
    check_license

    trap 'echo ""; print_info "Interrupted. Exiting."; exit 130' INT TERM

    # Main menu loop
    while true; do
        show_menu
        echo -ne "  ${CYAN}Select an option [1-4]: ${RESET}"
        read -r choice || { echo ""; print_info "End of input detected. Exiting."; exit 0; }

        # Default to option 1 if user just presses Enter
        choice=${choice:-1}

        case "$choice" in
            1)
                scrape_and_create
                ;;
            2)
                manual_add_user
                ;;
            3)
                view_created_users
                ;;
            4)
                echo ""
                print_info "Thank you for using DeelTech Solutions."
                echo -e "  ${DIM}Goodbye!${RESET}"
                echo ""
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-4."
                ;;
        esac

        echo ""
        echo -ne "  ${DIM}Press Enter to continue...${RESET}"
        read -r || exit 0
    done
}

# Run the program
main "$@"
