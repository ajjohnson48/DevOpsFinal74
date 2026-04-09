# Phase 3: CI/CD & Retrospective

**DeelTech Solutions — CSC2510 Final Project (Spring 2026)**

## Contents

| File | Description |
|------|-------------|
| `ci-cd/ci.yml` | GitHub Actions CI/CD workflow configuration |
| `Phase3_DeelTech_Solutions.pptx` | Phase 3 presentation (CI/CD & Retrospective) |
| `speaking_script.md` | Speaker notes for the presentation (~4:30 total) |
| `create_phase3_presentation.py` | Python script used to generate the .pptx file |

## CI/CD Pipeline

The pipeline (also located at `.github/workflows/ci.yml`) runs on every push and pull request:

1. **Lint** — ShellCheck static analysis on all `.sh` files
2. **Test** — Syntax validation (`bash -n`), permission checks, function verification
3. **Deploy** — Manual trigger; configured for SSH deployment to target VM

## Presentation

The Phase 3 presentation covers:
- CI/CD overview and pipeline design
- GitHub Actions workflow walkthrough
- Results and experience from using CI/CD
- Lessons learned across the project
- Process improvements for future work

Total presentation time: ~4:30 (4 speakers, ~1:00-1:15 each)
