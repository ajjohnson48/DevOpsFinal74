# DeelTech Solutions

## Faculty Account Automation System

### User Manual

**Version:** 1.0
**Date:** Spring 2026
**Course:** CSC2510 — DevOps Final Project
**Environment:** Ubuntu 24.04 / BASH 5.2.21

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [System Requirements](#2-system-requirements)
3. [Installation](#3-installation)
4. [First Run — License Activation](#4-first-run--license-activation)
5. [Main Menu Options](#5-main-menu-options)
6. [Username and Password Format](#6-username-and-password-format)
7. [Logging](#7-logging)
8. [Troubleshooting](#8-troubleshooting)
9. [Security Considerations](#9-security-considerations)
10. [Appendix — Faculty and Staff List](#10-appendix--faculty-and-staff-list)

---

## 1. Introduction

The Faculty Account Automation System is a command-line tool developed by DeelTech Solutions for automating the creation of Linux user accounts for Tennessee Tech University's Computer Science Department faculty and staff.

The tool scrapes the official TNTech CS faculty and staff web page, parses faculty names from the HTML, and creates Linux user accounts with standardized usernames and temporary passwords. It also supports manual user creation for ad-hoc account provisioning.

**Intended Audience:** System administrators responsible for provisioning faculty and staff accounts on Linux-based departmental servers.

---

## 2. System Requirements

| Requirement          | Specification                              |
|----------------------|--------------------------------------------|
| Operating System     | Ubuntu 24.04 LTS (or compatible)           |
| Shell                | BASH 5.2.21 or later                       |
| Privileges           | Root or sudo access (required for account creation) |
| Network Utilities    | `curl` or `wget` (at least one must be installed) |
| Internet Connection  | Required for scraping the faculty web page  |

---

## 3. Installation

**Step 1:** Obtain the script file `main.sh` from the delivery package. The script is located in the `scripts/` directory.

**Step 2:** Copy the script to the target system. For example:

```bash
scp scripts/main.sh admin@server:/opt/deeltech/main.sh
```

**Step 3:** Make the script executable:

```bash
chmod +x /opt/deeltech/main.sh
```

**Step 4:** Run the script with root privileges:

```bash
sudo /opt/deeltech/main.sh
```

The script can be placed in any directory on the target system. No additional dependencies or configuration files need to be installed beyond the system requirements listed in Section 2.

---

## 4. First Run — License Activation

On the first execution, the system will prompt for a **16-digit DeelTech license key**. This is a one-time activation step.

**What to expect:**

1. The application displays the DeelTech banner and enters the License Verification screen.
2. A message indicates that no valid license was found on the system.
3. You are prompted to enter a 16-digit license key in the format `XXXXXXXXXXXXXXXX`.

**Entering the key:**

```
  License Key: ________________
```

- The key must be exactly 16 characters.
- You have **3 attempts** to enter a valid key. After 3 failed attempts, the application will exit.
- If the key is fewer or more than 16 characters, the system will display an error and decrement the attempt counter.

**On successful activation:**

- A license file is created at `/etc/deeltech/.dtk_sys.dat`.
- The file stores a SHA-256 hash of the license key (not the key itself).
- The file permissions are set to `600` (owner read/write only).
- You will not be prompted for the license key again on subsequent runs.

**On subsequent runs:**

- The system automatically reads and verifies the stored license hash.
- If valid, the message `Valid license detected. Access granted.` is displayed and the main menu loads.
- If the license file has been corrupted or tampered with, it will be removed and you will be prompted to re-enter the key.

---

## 5. Main Menu Options

After license verification, the main menu is displayed:

```
  Main Menu
  ──────────────────────────────────────────────────────────
  1) Scrape Faculty & Create Users  (default)
  2) Add User Manually
  3) View Created Users
  4) Exit
  ──────────────────────────────────────────────────────────

  Select an option [1-4]:
```

Pressing Enter without typing a number defaults to **Option 1**.

---

### Option 1: Scrape Faculty and Create Users

This is the primary function of the application. It performs the following steps:

**Step 1 — Download the faculty page:**
The script downloads the HTML content of the TNTech CS faculty and staff page at:
`https://www.tntech.edu/engineering/programs/csc/faculty-and-staff.php`

The download is performed using `curl` (preferred) or `wget` if curl is not available.

**Step 2 — Parse faculty names:**
The script extracts faculty and staff names from the HTML by:
- Identifying names within `<h4><strong>` tags (most faculty members)
- Identifying names within `<h3>` tags (some staff members)
- Stripping HTML tags and entities
- Removing degree suffixes (e.g., "Ph.D.")
- Filtering out section headers and category labels

**Step 3 — Display parsed names:**
A formatted table is displayed showing each person's first name, last name, and a sequential number:

```
  ──────────────────────────────────────────────────────────
  #    First Name           Last Name
  ──────────────────────────────────────────────────────────
  1    Ambareen             Siraj
  2    Sheikh               Ghafoor
  ...
  ──────────────────────────────────────────────────────────
  Total: 42 faculty/staff members found.
```

**Step 4 — Confirm creation:**
The script prompts:
```
  Proceed with user account creation? (y/n):
```

- Enter `y` or `Y` to proceed with account creation for all listed names.
- Enter `n` or any other key to cancel.

**Step 5 — Create accounts:**
If confirmed, the script creates a Linux user account for each parsed name. For each user:
- A username is generated in the format `first.last` (lowercase).
- A password is set in the format `FirstLastDEELTECH`.
- A home directory is created at `/home/first.last`.
- The default shell is set to `/bin/bash`.
- If a user already exists, it is skipped with a warning.

**Step 6 — Display summary:**
After processing all names, a summary is displayed:

```
  Account Creation Summary
  ──────────────────────────────────────────────────────────
  Total processed:  42
  Created:          40
  Skipped (exist):  2
  Failed:           0
  ──────────────────────────────────────────────────────────
```

---

### Option 2: Add User Manually

This option allows you to create a single user account by manually entering a first and last name.

**Prompts:**

```
  Enter first name: John
  Enter last name:  Smith

  Username: john.smith
  Password: JohnSmithDEELTECH

  Create this user? (y/n):
```

- Both fields are required. If either is left blank, an error is displayed.
- Leading and trailing whitespace is trimmed from the entered names.
- The generated username and password are displayed for confirmation before creation.
- Enter `y` or `Y` to create the account, or `n` to cancel.

---

### Option 3: View Created Users

Displays a formatted table of all user accounts previously created by the application:

```
  ──────────────────────────────────────────────────────────
  Date/Time              Username             Full Name
  ──────────────────────────────────────────────────────────
  2026-04-09 14:32:01    ambareen.siraj       Ambareen Siraj
  2026-04-09 14:32:01    sheikh.ghafoor       Sheikh Ghafoor
  ...
  ──────────────────────────────────────────────────────────
  Total created users: 42
```

This data is read from the log file at `/var/log/deeltech_created_users.log`. If no users have been created yet, the message `No users have been created yet.` is displayed along with the log file path.

---

### Option 4: Exit

Displays a goodbye message and terminates the application.

```
  Thank you for using DeelTech Solutions.
  Goodbye!
```

---

## 6. Username and Password Format

All user accounts follow a consistent naming and password scheme:

| Field    | Format                       | Example (for "John Smith")   |
|----------|------------------------------|------------------------------|
| Username | `firstname.lastname`         | `john.smith`                 |
| Password | `FirstnameLastnameDEELTECH`  | `JohnSmithDEELTECH`         |

**Username rules:**
- The username is composed of the first name and last name separated by a period.
- All characters are converted to lowercase.
- For names parsed from the web page, the first word is used as the first name and the last word is used as the last name.

**Password rules:**
- The password is composed of the first name followed by the last name followed by the suffix `DEELTECH`.
- The original capitalization of the first and last name is preserved in the password.
- For scraped names, the capitalization as it appears on the web page is used.

---

## 7. Logging

Every user account created by the application is logged to:

```
/var/log/deeltech_created_users.log
```

**Log entry format:**

```
YYYY-MM-DD HH:MM:SS | Created user: first.last | Name: First Last
```

**Example entries:**

```
2026-04-09 14:32:01 | Created user: ambareen.siraj | Name: Ambareen Siraj
2026-04-09 14:32:01 | Created user: sheikh.ghafoor | Name: Sheikh Ghafoor
2026-04-09 14:35:12 | Created user: john.smith | Name: John Smith
```

This log file is appended to each time users are created. It is not overwritten. The log is used by **Option 3 (View Created Users)** to display the history of account creation.

---

## 8. Troubleshooting

### "This operation requires root privileges."

The script must be run with root access to create user accounts. Run the script with `sudo`:

```bash
sudo ./main.sh
```

### "Neither curl nor wget is installed."

The script requires either `curl` or `wget` to download the faculty web page. Install one:

```bash
sudo apt install curl
```

### "Failed to download the faculty page."

This error indicates a network issue. Verify:
- The system has an active internet connection.
- DNS resolution is working (`ping www.tntech.edu`).
- No firewall rules are blocking outbound HTTP/HTTPS traffic.
- The URL `https://www.tntech.edu/engineering/programs/csc/faculty-and-staff.php` is accessible from the system.

### "Key must be exactly 16 characters."

The license key must be exactly 16 alphanumeric characters with no spaces, hyphens, or other separators. Re-enter the key without any formatting.

### "Too many failed attempts. Access denied."

After 3 incorrect license key entries, the application exits. Re-run the script to try again. Contact DeelTech Solutions support if you do not have a valid key.

### "License file is corrupted or invalid."

The license file at `/etc/deeltech/.dtk_sys.dat` has been modified or corrupted. The application will automatically delete the corrupted file and prompt for the license key again on the next run.

### "No users have been created yet." (Option 3)

This message appears when the log file `/var/log/deeltech_created_users.log` does not exist. It will be created automatically the first time a user account is successfully created.

### "No names were parsed from the faculty page."

The HTML structure of the TNTech faculty page may have changed. Verify the page is accessible in a web browser. If the page layout has been restructured, the parsing logic may need to be updated.

---

## 9. Security Considerations

### Temporary Passwords

The passwords generated by this tool are intended as **temporary initial passwords**. They follow a predictable pattern based on the user's name. It is strongly recommended that all users be required to change their password upon first login.

To force a password change on first login for a specific user:

```bash
sudo passwd --expire username
```

### Password Storage Improvement

The current implementation sets passwords using the `chpasswd` utility with plaintext password strings. For production deployments, the recommended improvement is to hash passwords using **SHA-512** before passing them to the system. This can be accomplished with:

```bash
echo "username:$(openssl passwd -6 'password')" | chpasswd -e
```

### License File Protection

The license file at `/etc/deeltech/.dtk_sys.dat` is stored with permissions `600` (read/write for root only). This file contains a SHA-256 hash of the license key, not the key itself. Do not modify this file manually. If the file becomes corrupted, delete it and re-enter the license key on the next run:

```bash
sudo rm /etc/deeltech/.dtk_sys.dat
```

### Log File Access

The log file at `/var/log/deeltech_created_users.log` contains usernames and full names but does not contain passwords. Standard file system permissions should be applied to restrict read access to authorized administrators only:

```bash
sudo chmod 640 /var/log/deeltech_created_users.log
```

---

## 10. Appendix — Faculty and Staff List

The following is the list of 42 faculty and staff members extracted from the TNTech CS Department faculty and staff web page. These are the names processed by Option 1 (Scrape Faculty and Create Users).

| #  | First Name    | Last Name     | Generated Username       |
|----|---------------|---------------|--------------------------|
| 1  | Ambareen      | Siraj         | ambareen.siraj           |
| 2  | Sheikh        | Ghafoor       | sheikh.ghafoor           |
| 3  | William       | Eberle        | william.eberle           |
| 4  | Mike          | Rogers        | mike.rogers              |
| 5  | Maanak        | Gupta         | maanak.gupta             |
| 6  | Doug          | Talbert       | doug.talbert             |
| 7  | Gerald        | Gannod        | gerald.gannod            |
| 8  | Michael       | Collotta      | michael.collotta         |
| 9  | Martha        | Kosa          | martha.kosa              |
| 10 | Syed          | Ahmed         | syed.ahmed               |
| 11 | Syed Rafay    | Hasan         | syed.hasan               |
| 12 | Mohammad      | Khan          | mohammad.khan            |
| 13 | Susmit        | Shannigrahi   | susmit.shannigrahi       |
| 14 | Ahnaf         | Islam         | ahnaf.islam              |
| 15 | Shatabdi      | Acharya       | shatabdi.acharya         |
| 16 | Nurjahan      | Raunak        | nurjahan.raunak          |
| 17 | Oluwatobi     | Akomolafe     | oluwatobi.akomolafe      |
| 18 | Farah         | Naz           | farah.naz                |
| 19 | Ishmam        | Towhid        | ishmam.towhid            |
| 20 | Sadia         | Sultana       | sadia.sultana            |
| 21 | Pankaj        | Shah          | pankaj.shah              |
| 22 | Bhavin        | Shah          | bhavin.shah              |
| 23 | Indrajit      | Ray           | indrajit.ray             |
| 24 | Elham         | Sahebkar      | elham.sahebkar           |
| 25 | Allan         | Mills         | allan.mills              |
| 26 | Alfred        | Kalfas        | alfred.kalfas            |
| 27 | Khalid        | Imam          | khalid.imam              |
| 28 | Brandon       | Gant          | brandon.gant             |
| 29 | Eduardo       | Colmenares    | eduardo.colmenares       |
| 30 | Justin        | Deloach       | justin.deloach           |
| 31 | Derek         | Pyle          | derek.pyle               |
| 32 | Jeffrey       | Ward          | jeffrey.ward             |
| 33 | Carolina      | Davis         | carolina.davis           |
| 34 | Lee           | Brown         | lee.brown                |
| 35 | Ernesto       | Gomez         | ernesto.gomez            |
| 36 | Jerry         | Gannod        | jerry.gannod             |
| 37 | Rob           | Gillette      | rob.gillette             |
| 38 | Denis         | Ulybyshev     | denis.ulybyshev          |
| 39 | Mike          | Renfro        | mike.renfro              |
| 40 | Jennifer      | Murphy        | jennifer.murphy          |
| 41 | Megan         | Miller        | megan.miller             |
| 42 | Holly         | Hanson        | holly.hanson             |

**Note:** The exact number and names may vary if the TNTech web page is updated. The list above reflects the page content at the time of this document's creation.

---

*DeelTech Solutions — Faculty Account Automation System v1.0*
*CSC2510 DevOps Final Project — Spring 2026*
