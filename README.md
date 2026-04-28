# DeelTech Solutions — Faculty Account Automation System

CSC2510 DevOps Final Project — Spring 2026

## Overview

Automated BASH tool for onboarding Tennessee Tech University CS Department faculty and staff. Scrapes the faculty directory, creates Linux user accounts, and enforces license-based access control.

## Quick Start

```bash
chmod +x scripts/main.sh
sudo ./scripts/main.sh
```

## Project Structure

```
.
├── scripts/
│   └── main.sh                  # Main application script
├── docs/
│   └── user_manual.md           # Usage manual and documentation
├── presentation/
│   └── Phase1_DeelTech_Solutions.pptx
├── test/
│   ├── demo/
│   │   └── demo_walkthrough.txt # Full application demo output
│   ├── 01_license_tests.txt     # License system test results
│   ├── 02_menu_tests.txt        # Menu navigation tests
│   ├── 03_scraper_tests.txt     # Web scraper tests
│   ├── 04_manual_add_tests.txt  # Manual add user tests
│   ├── 05_view_users_tests.txt  # View users tests
│   ├── 06_exit_test.txt         # Exit handling test
│   ├── 07_edge_cases.txt        # Edge case tests (EOF, SIGINT, etc.)
│   └── 08_test_summary.txt      # Full regression summary (35/35 PASS)
├── .github/workflows/
│   └── ci.yml                   # CI/CD pipeline (ShellCheck + tests)
└── README.md
```

## Features

- **Web Scraper** — Downloads and parses the TNTech CS faculty page for 42+ names
- **Batch User Creation** — Generates usernames (`first.last`) and 12-character random passwords, creates Linux accounts
- **Manual Add User** — Interactive prompt for adding individual accounts
- **Password Rotation** — Menu option 4 rotates every previously created account's password (incident response)
- **License Enforcement** — 16-digit key with obfuscated validation and persistent license file
- **Input Validation** — Regex whitelisting, length checks, shell metacharacter rejection
- **Signal Handling** — Clean exit on EOF, SIGINT, and SIGTERM

## Security Model

- **Random passwords** — 12 alphanumeric characters per user, generated from `/dev/urandom`. Never echoed to the terminal.
- **First-login change forced** — every account is created (or rotated) with `chage -d 0`, so the user must change their password on first login. The plaintext password is a one-shot delivery token.
- **Credentials file** — written to `/root/deeltech/credentials.txt` with mode `600`, owned by root. Same protection model as `/etc/shadow`.
- **Rotation** — menu option 4 reads the script's user log (never `/etc/passwd`) and rotates only accounts this script created. New passwords are appended to the credentials file with a `(rotated)` tag.
- **Dissemination** — the admin emails the credentials file to the responsible party out-of-band, then runs `shred -u` after receipt is confirmed. See `docs/user_manual.md` §9 for details.

## Requirements

- Ubuntu 24.04 LTS
- BASH 5.2.21
- Root/sudo access
- curl
- Internet connection (for web scraping)

## Team

| Name | Role |
|------|------|
| Beshoy Farag | Project Manager |
| Canaan Jackson | Lead Developer |
| Koby Zhang | DevOps Engineer |
| Anthony Johnson | QA / Documentation Lead |
