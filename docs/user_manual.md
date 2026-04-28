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
  4) Rotate All Passwords  (security response)
  5) Exit
  ──────────────────────────────────────────────────────────

  Select an option [1-5]:
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
- A 12-character random alphanumeric password is generated from `/dev/urandom`. The password is **never displayed on the terminal** — it is written only to the credentials file at `/root/deeltech/credentials.txt` (mode `600`, root-owned).
- `chage -d 0` is applied so the user must change the password on first login.
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
  Password: (random — recorded in /root/deeltech/credentials.txt after creation)

  Create this user? (y/n):
```

- Both fields are required. If either is left blank, an error is displayed.
- Leading and trailing whitespace is trimmed from the entered names.
- The username is shown for confirmation. The password is generated only after you confirm and is written to the credentials file — it is not displayed on the terminal.
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

### Option 4: Rotate All Passwords

This option is the **security incident response** workflow. It generates a new random 12-character password for every user previously created by this script and rewrites their account passwords. New credentials are appended to `/root/deeltech/credentials.txt` with a `(rotated)` tag.

**When to use:**
- A breach is suspected or confirmed.
- The default-password scheme (used by older versions of the script) needs to be invalidated across all existing accounts.
- A scheduled rotation policy requires it.

**Behavior:**
- Reads the script's user log at `/var/log/deeltech_created_users.log` to determine which accounts to rotate. The script never reads `/etc/passwd` directly, so system accounts (`root`, `nobody`, `systemd-resolve`, etc.) are **never** touched.
- For each logged user:
  - If the account no longer exists in `/etc/passwd`, it is skipped and counted as `Missing`.
  - Otherwise, a new 12-character password is generated, set via `chpasswd`, and `chage -d 0` is applied so the user must change the password on next login.
  - The new credential is appended to `/root/deeltech/credentials.txt`.
- A summary is shown:

```
  Rotation Summary
  ──────────────────────────────────────────────────────────
  Total:    42
  Rotated:  42
  Missing:  0
  Failed:   0
  ──────────────────────────────────────────────────────────
```

After rotation, the credentials file should be transmitted to the responsible administrator out of band (see §9 — *Disseminating Credentials*) and then `shred -u`'d once receipt is confirmed.

---

### Option 5: Exit

Displays a goodbye message and terminates the application.

```
  Thank you for using DeelTech Solutions.
  Goodbye!
```

---

## 6. Username and Password Format

All user accounts follow a consistent naming and password scheme:

| Field    | Format                                       | Example (for "John Smith")   |
|----------|----------------------------------------------|------------------------------|
| Username | `firstname.lastname`                         | `john.smith`                 |
| Password | 12 random alphanumeric chars (`/dev/urandom`)| `aB3xK9pQ2mR7`               |

**Username rules:**
- The username is composed of the first name and last name separated by a period.
- All characters are converted to lowercase.
- For names parsed from the web page, the first word is used as the first name and the last word is used as the last name.

**Password rules:**
- Each password is generated independently from `/dev/urandom` and consists of 12 alphanumeric characters drawn from `[A-Za-z0-9]`. Special characters are intentionally excluded to keep passwords safe to copy/paste, type at a terminal, and embed in shell tooling.
- Passwords are **never echoed to the terminal**. They are persisted only to `/root/deeltech/credentials.txt` (mode `600`, owner `root:root`).
- Every newly created or rotated account has `chage -d 0` applied. This forces the user to change the password at first login, so the random password the script generates is effectively a one-shot delivery token.

**Credentials file format:**

```
YYYY-MM-DD HH:MM:SS | username               | password     | Full Name [tag]
```

Example:

```
2026-04-27 19:30:11 | john.smith             | aB3xK9pQ2mR7 | John Smith
2026-04-27 19:31:02 | ambareen.siraj         | qZ8nM4pK7vR1 | Ambareen Siraj (rotated)
```

The `(rotated)` tag identifies rows written by **Option 4** (password rotation). Rows without a tag are first-time creations.

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

### Random Passwords (Phase 3 Security Revision)

Earlier versions of this tool generated deterministic passwords of the form `FirstnameLastnameDEELTECH`, which proved trivially guessable. This release replaces that scheme with **12-character random alphanumeric passwords** drawn from `/dev/urandom` (a kernel-grade CSPRNG). Each password is independent of the user's name and of every other password in the system.

### Forced Password Change at First Login

Every account created or rotated by this script has `chage -d 0 <username>` applied automatically. This sets the user's last-password-change date to epoch zero, which Linux interprets as "must be changed before the user can reach a shell." The plaintext password the script writes to the credentials file is therefore a **one-shot delivery token** — valid for exactly one login, then dead.

You can verify this is in effect for any user with:

```bash
sudo chage -l john.smith
# Output should include: "Password expires : password must be changed"
```

### Credentials File

The credentials file at `/root/deeltech/credentials.txt` contains username/password pairs in plaintext. It is created with:

- Owner `root:root`
- Mode `600` (read/write for root only — same protection model as `/etc/shadow`)
- Parent directory `/root/deeltech` at mode `700`
- `umask 077` set before writing, so file creation never has a window of looser permissions

No other file in the system contains plaintext passwords — the kernel will refuse `cat` to anyone other than root.

### Password Rotation (Incident Response)

**Option 4 — Rotate All Passwords** is the script's incident-response workflow. Use it when:

- A breach is suspected, confirmed, or being audited.
- Users have not changed their initial passwords (the original incident scenario).
- A scheduled rotation policy is in effect.

The function reads `/var/log/deeltech_created_users.log` to determine which accounts to rotate. **Only accounts this script created are touched.** System accounts (`root`, `nobody`, `systemd-resolve`, etc.) are never seen by the rotation logic because they are not in the script's user log. If an account in the log no longer exists in `/etc/passwd` (e.g., an admin ran `userdel`), it is counted as `Missing` and skipped.

### Disseminating Credentials

After running batch creation or rotation, the credentials file must be transmitted to the responsible administrator (typically Mr. Billings, per the Phase 3 task) so individual passwords can be communicated to the affected users. Recommended workflow:

1. **Encrypt before transmission.** Either GPG-encrypt with the recipient's public key:
   ```bash
   gpg --encrypt --recipient billings@tntech.edu /root/deeltech/credentials.txt
   ```
   …or use a password-protected zip and communicate the zip password out-of-band (text message or phone call):
   ```bash
   zip -e credentials.zip /root/deeltech/credentials.txt
   ```
2. **Send via email**, attaching only the encrypted artifact.
3. **Confirm receipt** with the recipient through a separate channel.
4. **Securely delete the local plaintext** after receipt is confirmed:
   ```bash
   sudo shred -u /root/deeltech/credentials.txt
   ```

Combined with `chage -d 0`, even a residual disk-forensics recovery yields passwords that are already invalidated by the time the recovery is performed.

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
