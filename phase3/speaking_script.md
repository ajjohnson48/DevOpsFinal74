# Phase 3 Presentation Speaking Script

**Total Time Target: ~4:30 (safely above the 4-minute minimum)**

Each section is approximately 1:00 to 1:15 minutes.

---

## BESHOY FARAG (Project Manager) — Slides 1, 2, 3 (~1:10)

### Slide 1 — Title Slide

> Good morning/afternoon everyone. We are the DeelTech Solutions DevOps Team, and today we are presenting Phase 3 of our CSC2510 Final Project. This phase covers our continuous integration and delivery implementation, as well as our retrospective on the entire project — the lessons we learned and the improvements we would make next time.

### Slide 2 — Agenda

> Here is what we will be covering. First, we will give an overview of CI/CD and explain why we adopted it for this project. Then we will walk through our pipeline design and show our GitHub Actions workflow in action. After that, we will share the results of using CI/CD throughout our development process, discuss the lessons we learned, and talk about what we would do differently if we started over. We will wrap up with a conclusion and open the floor for questions.

### Slide 3 — CI/CD Overview

> So, to set the stage — what is CI/CD? Continuous integration means that every time a team member pushes code, the system automatically runs checks against that code. Continuous delivery extends that by preparing the code for deployment after those checks pass. For our project, we adopted CI/CD because we have a critical BASH script that manages user accounts on a production system. Bugs in that script could mean broken accounts, incorrect permissions, or even security vulnerabilities. By setting up automated checks, we made sure that every change was validated before it could reach the main branch. It shifted our approach from hoping things work to knowing they work.

---

## CANAAN JACKSON (Lead Developer) — Slides 4, 5 (~1:10)

### Slide 4 — Our Pipeline

> Let me walk through the pipeline we built. It has three stages. The first stage is linting with ShellCheck. ShellCheck is a static analysis tool for shell scripts, and it catches things like unquoted variables, incorrect conditionals, and unsafe patterns that are easy to miss during manual review. The second stage is testing, where we validate every script using bash dash-n for syntax correctness, we verify that the file permissions are set properly, and we confirm that all required functions — like check_license, scrape_faculty, and create_user — are present in the script. The third stage is deployment. Right now, we have the deploy job configured as a manual trigger, because our target VM is local and not reachable from GitHub's runners. In a production environment, this stage would SSH into the target machine and pull the latest changes automatically.

### Slide 5 — CI/CD in Action

> Here is how the workflow actually runs. We configured GitHub Actions to trigger on every push to the main and develop branches, and on every pull request targeting main. So any time someone opens a PR, the pipeline kicks off automatically. The lint job runs first and has to pass before the test job starts. This ordering is intentional — there is no point running validation tests if the script has linting errors. Each step produces clear pass/fail output in the Actions tab, so the team can see exactly what broke and where. The whole pipeline typically runs in under a minute, so we get nearly instant feedback on every change.

---

## KOBY ZHANG (DevOps Engineer) — Slides 6, 7 (~1:10)

### Slide 6 — CI/CD Results and Experience

> Now let me share what we gained from using CI/CD. The biggest win was catching issues early. ShellCheck flagged quoting problems and unsafe variable expansions that none of us caught during code review. The syntax validation step also caught a bracket mismatch after a late-night edit that would have broken the entire script at runtime. Beyond catching bugs, CI/CD enforced consistency across the team. Everyone had to meet the same quality bar before their code could be merged. And from a workflow standpoint, pull requests became much more efficient. Instead of manually running through a checklist, the pipeline handled the verification, and reviewers could focus on logic and design rather than syntax.

### Slide 7 — Lessons Learned

> We learned several important lessons through this process. First, start CI/CD early. We set up the pipeline partway through development, and we wish we had done it on day one. Every commit before the pipeline existed was essentially unvalidated. Second, ShellCheck catches bugs that humans miss. Things like unquoted variables inside conditionals or missing error handling on subshells — these are subtle issues that are hard to spot by eye. Third, branch protection is essential. Requiring the pipeline to pass before merging prevented us from accidentally pushing broken code to main. Fourth, writing testable scripts requires upfront planning. We had to structure our code with clearly defined functions so the pipeline could verify their existence. And fifth, documentation should be maintained alongside the code, not tacked on at the end. Keeping our docs current as we developed saved us significant rework.

---

## ANTHONY JOHNSON (QA / Documentation Lead) — Slides 8, 9, 10 (~1:00)

### Slide 8 — Process Improvements

> If we could start over, here is what we would do differently. First, set up CI/CD on day one. Even a basic lint check from the first commit would have caught issues earlier. Second, we would add more comprehensive test coverage using a framework like BATS — the Bash Automated Testing System — to write unit tests for each function. Third, we would implement pre-commit hooks locally, so issues get caught before they even reach the remote repository. Fourth, we would adopt semantic versioning with tagged releases to clearly track which version of the script is deployed. And fifth, we would add an automated deployment stage to a staging environment first, so changes get tested in a real Ubuntu VM before going to production.

### Slide 9 — Conclusion

> To wrap up, Phase 3 brought the DevOps philosophy full circle for our project. We built a functional CI/CD pipeline that automatically validates every change through linting, syntax checking, and structural verification. The pipeline gave us confidence that our script meets quality standards before any code reaches production. More importantly, this project taught us that DevOps is not just about tools — it is about building a culture of automation, accountability, and continuous improvement. Our team has grown significantly through this process, and we are taking these practices forward into our future work.

### Slide 10 — Questions

> That concludes our Phase 3 presentation. Thank you for your time. We are happy to take any questions.

---

## Timing Notes

| Speaker | Slides | Approx. Time |
|---------|--------|---------------|
| Beshoy Farag | 1, 2, 3 (Title, Agenda, CI/CD Overview) | ~1:10 |
| Canaan Jackson | 4, 5 (Pipeline, CI/CD in Action) | ~1:10 |
| Koby Zhang | 6, 7 (Results, Lessons Learned) | ~1:10 |
| Anthony Johnson | 8, 9, 10 (Improvements, Conclusion, Questions) | ~1:00 |
| **Total** | **10 slides** | **~4:30** |

**Tips:**
- Practice reading your section aloud at a natural pace — aim for about 1 minute each
- Do not rush. Pausing briefly between slides helps the audience absorb the content
- Make eye contact with the audience, not the slides — these notes are your guide
- The acceptance discussion after "Questions" does not count against your time
