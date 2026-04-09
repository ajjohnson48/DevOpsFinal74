# Phase 1 Presentation Speaking Script

**Total Time Target: 8 minutes (7:30 - 8:30 for full credit)**

Each section is approximately 2 minutes. Speakers are labeled as **Speaker 1** through **Speaker 4** — replace with your actual names.

---

## SPEAKER 1 — Slides 1, 2, 3 (~2 minutes)

### Slide 1 — Title Slide

> Good morning/afternoon everyone. We are the DeelTech Solutions DevOps Team, and today we will be presenting our Phase 1 plan for the CSC2510 Final Project. Our project focuses on building a DevOps onboarding automation system for Tennessee Tech's Computer Science faculty and staff.

### Slide 2 — Agenda

> Here is a quick overview of what we will be covering today. We will start with the problem we are solving and the scope of work. Then we will go over our team roles, our development approach for each of the four technical parts, and some recommended improvements we would like to propose. After that, we will discuss our collaboration tools, delivery timeline with risk scenarios, and our CI/CD strategy. We will wrap up with a conclusion and open the floor for questions.

### Slide 3 — Problem Statement

> So, what is the problem? DeelTech Solutions has been hired to create a secure internal portal for faculty members in the TNTech Computer Science Department. Before that portal can go live, we need user accounts for every faculty and staff member. Right now, there are over 42 people who need accounts, and doing that by hand is slow and error-prone. There is no standardized process for assigning usernames or passwords, and no automated way to pull current faculty data from the department website. Our job is to eliminate that manual work entirely by building a BASH automation program that handles the full onboarding pipeline — from scraping the names off the website to creating the accounts on the system.

---

## SPEAKER 2 — Slides 4, 5, 6 (~2 minutes)

### Slide 4 — Scope of Work

> Our solution is broken into four technical deliverables. Part 1 is a web scraping engine. We will use curl to download the TNTech CS faculty page and then parse out all the first and last names using standard text processing tools like grep, sed, and awk. Part 2 takes that list of names and automatically creates Linux user accounts. Each username follows the format first-dot-last, all lowercase, and the password is the first name, last name, and the word DEELTECH concatenated together. Part 3 is a manual add-user function for cases where someone needs to be added individually outside of the scrape. And Part 4 is a licensing system — the script will check for a valid license file on startup, and if one does not exist, it will prompt for a 16-digit key. That key is obfuscated in the code so it cannot be read in plain text. Our target environment is Ubuntu 24.04 with BASH version 5.2.21 running on a VirtualBox VM.

### Slide 5 — Team Roles

> For team organization, we have divided responsibilities into four roles. Our Project Manager and Scrum Master handles sprint planning, stakeholder communication, and risk tracking. Our Lead Developer owns the core script architecture, the web scraping implementation, and code quality reviews. Our DevOps Engineer is responsible for the CI/CD pipeline, VM environment setup, and deployment automation. And our QA and Documentation Lead handles testing, the user manual, and presentation preparation. Each of us will be contributing code, but these roles define who owns each area of the project.

### Slide 6 — Development Approach

> Let me walk through how we are building each part technically. For Part 1, we fetch the HTML with curl and run it through a pipeline of grep and sed commands to extract names from the page markup. We handle edge cases like hyphenated names and middle initials. For Part 2, we loop through the parsed name list, generate the username and password according to the schema, and use useradd and chpasswd to create each account in batch. Part 3 is an interactive BASH function that prompts the user for a first and last name, validates the input, and creates the account using the same conventions. For Part 4, we designed a license key obfuscation system. The valid key is encoded within the script using techniques like base64 encoding and variable splitting so that it cannot be found by simply reading the source. On startup, the script checks for a license file, and if it is missing, it prompts the user and validates their input against the obfuscated key.

---

## SPEAKER 3 — Slides 7, 8, 9 (~2 minutes)

### Slide 7 — Recommended Improvements

> Beyond the base requirements, we would like to propose four improvements. First, password hashing. Right now passwords are set in a basic format, but we recommend using SHA-512 hashing through chpasswd's built-in encryption flag so that passwords are never stored in cleartext. Second, LDAP or Active Directory integration, which would allow these accounts to work across multiple campus systems rather than just the local machine. Third, an email notification system that automatically sends new users a welcome message with their credentials and first-login instructions. And fourth, audit logging with rollback capability, so that administrators have a timestamped record of every account operation and can reverse changes if something goes wrong.

### Slide 8 — Collaboration and Tools

> For collaboration, we are using GitHub as our central repository with a protected main branch. Our branching strategy uses feature branches — each team member works on their own feature branch and submits a pull request to merge into main. Every pull request requires at least one reviewer approval before it can be merged. We use semantic commit messages so that the history is easy to follow. For communication, we hold daily standups over Discord, run sprint retrospectives after each phase, and track issues using GitHub Issues with labels for priority and category.

### Slide 9 — Delivery Timeline

> We have planned for three scenarios. In our probable scenario, all four parts are delivered and functional by the deadline. The web scraper parses the faculty page correctly, both the automated and manual account creation are working end to end, and the licensing system is tested and documented. In our best-case scenario, we finish the core deliverables early, which gives us time to add bonus features like a user deletion function and bulk import from a CSV file, along with extra polish like colored terminal output and progress indicators. In our worst-case scenario, the main risk is the web scraper breaking if TNTech changes their page structure. Our mitigation for that is a fallback to a manual name list from a text file. Parts 2 through 4 are completely independent of the scraper, so even if Part 1 has issues, the rest of the project is still deliverable on time.

---

## SPEAKER 4 — Slides 10, 11, 12 (~2 minutes)

### Slide 10 — CI/CD Strategy

> For continuous integration and delivery, we are using GitHub Actions. Every push and every pull request to the main branch triggers our pipeline. The first step is linting — we run ShellCheck, which is a static analysis tool for BASH scripts, to catch syntax errors and style issues automatically. Next, we run our automated test suite using BATS, the Bash Automated Testing System, which validates each of the four parts individually. After that comes the code review step through pull requests. And finally, once all checks pass on main, we deploy the script to our test VM using SSH and SCP. This gives us confidence that every change is validated before it reaches the deployment target.

### Slide 11 — Conclusion

> To summarize, our key deliverables are a fully automated BASH onboarding script with four components: the web scraper, automated account creation, manual add-user functionality, and license key enforcement with obfuscation. On top of that, we are delivering a complete CI/CD pipeline and full documentation including a user guide. Our next steps are to finalize our role assignments, set up the GitHub repository with branch protection, configure the CI/CD pipeline, and begin development starting with the web scraper. We are confident in our ability to deliver a robust, production-quality solution. Our team has strong experience with BASH scripting, Linux administration, and DevOps practices, and we have a clear plan with proactive risk mitigation in place.

### Slide 12 — Questions

> That concludes our Phase 1 presentation. Thank you for your time. We are happy to take any questions.

---

## Timing Notes

| Speaker | Slides | Approx. Time |
|---------|--------|---------------|
| Speaker 1 | 1, 2, 3 (Title, Agenda, Problem) | ~2:00 |
| Speaker 2 | 4, 5, 6 (Scope, Roles, Dev Approach) | ~2:00 |
| Speaker 3 | 7, 8, 9 (Improvements, Collab, Timeline) | ~2:00 |
| Speaker 4 | 10, 11, 12 (CI/CD, Conclusion, Questions) | ~2:00 |
| **Total** | **12 slides** | **~8:00** |

**Tips:**
- Practice reading your section aloud at a natural pace — aim for about 2 minutes each
- Do not rush. Pausing briefly between slides helps the audience absorb the content
- Make eye contact with the audience, not the slides — these notes are your guide
- The acceptance discussion after "Questions" does not count against your time
