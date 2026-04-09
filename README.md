# DeelTech Solutions — Faculty Account Automation System

CSC2510 DevOps Final Project — Spring 2026

## Overview

Automated BASH tool for onboarding Tennessee Tech University CS Department faculty and staff. Scrapes the faculty directory, creates Linux user accounts, and enforces license-based access control.

## Quick Start

```bash
cd scripts/
chmod +x main.sh
sudo ./main.sh
```

## Project Structure

```
.
├── scripts/
│   └── main.sh              # Main application script
├── phase1/                   # Phase 1 deliverables (presentation + code)
├── phase2/                   # Phase 2 deliverables (code + user manual)
├── phase3/                   # Phase 3 deliverables (CI/CD + presentation)
├── .github/workflows/        # CI/CD pipeline configuration
└── README.md
```

## Turn-In Folders

| Phase | Contents |
|-------|----------|
| `phase1/` | Planning presentation (.pptx), speaking script, initial code |
| `phase2/` | Finalized code, user manual, deployment README |
| `phase3/` | CI/CD config, retrospective presentation, speaking script |

## Requirements

- Ubuntu 24.04 LTS
- BASH 5.2.21
- Root/sudo access
- curl or wget
- Internet connection (for web scraping)
