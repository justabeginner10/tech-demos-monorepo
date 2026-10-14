# Daily SwiftUI demo — Codex cloud task

Schedule this task **every day at 09:00 Asia/Kolkata (IST)**, equivalent to **03:30 UTC**. Select the cloud environment for `justabeginner10/tech-demos-monorepo`, starting from `main`. The execution must be hosted in the cloud so it does not depend on a running laptop.

These are task instructions; committing this file does **not** register or activate a schedule. Register the recurring cloud task in a scheduling interface that supports cloud execution. No scheduling tool is available in the chat that prepared this file.

## Task prompt

Create one small iOS/SwiftUI demo app in justabeginner10/tech-demos-monorepo and open one pull request against main.

Use the existing isolated cloud checkout; do not create a Git worktree unless explicitly requested. Read AGENTS.md if present, the root README, and two recent apps for conventions. Preserve pre-existing user changes. Start a new branch from the current remote main without resetting user work.

Inspect apps/, the root demo list, and open pull requests before selecting a library. Choose a small public SwiftUI library that is not already demonstrated or proposed in an open PR. Use its official repository, verify its license permits integration, read its actual public API and Package.swift, and pin a released version and full revision. Avoid private dependencies, credentials, and unnecessarily large integrations. If PR listing is inaccessible, report that and use existing demos and remote branches to reduce duplicates; do not claim to have checked open PRs.

Create apps/<kebab-slug>/ following this monorepo's conventions: iOS 18+ unless the dependency requires a newer documented SDK, Swift 6, a distinct Demo module name, com.techdemos bundle ID, Sources/, project.yml, a checked-in .xcodeproj, shared scheme, and Package.resolved. Prefer a focused Live tab with a few meaningful controls and a static Gallery tab. Keep animations off in the gallery and honor Reduce Motion. Demonstrate the real library API in the live app. Keep unrelated apps unchanged. Update the root README demo list and add an app README covering the dependency pin, requirements, launch steps, controls, expected behavior, and validation results.

Use Mac/Xcode and an iOS simulator when available. Build the selected scheme with the committed package versions, run it, exercise the primary controls, and capture at least one simulator screenshot and one video as requested by the repository. Verify meaningful existing tests when available; an empty test run is not a pass. If only Linux is available, inspect dependency APIs and project structure, explicitly state that build/runtime checks and captures were not performed, and open the PR as a draft. Do not fabricate screenshots, videos, or passing results. A Linux toolchain cannot compile SwiftUI/UIKit apps.

Review the diff, commit only this task's files, push the branch, and create one PR with base main. Explain the library, observable demo behavior, exact checks performed, and remaining validation. Never merge automatically. Use existing platform GitHub authentication; successful Git reads alone do not establish API or PR creation permission. Attach the created PR to the task when the attachment tool is available. If push or PR creation is denied, preserve the work and report the precise blocker and branch rather than claiming a PR exists.

If a same-day scheduled task has already created a demo PR, report its link and stop instead of opening a duplicate. Finish with the PR link, library selected, and validation status.

## Prerequisites

- Activate the recurring cloud task in the scheduling interface; this file is only its prompt.
- Allow `api.github.com` in the cloud environment network settings and provide supported GitHub API authentication with permission to create branches and pull requests. Git HTTPS reads use the existing platform proxy.
- Publish the prepared cloud environment after reviewing its settings so future cloud tasks can restore it.
- Simulator builds and captures require a cloud Mac runner with Xcode; the prepared Linux environment supports authoring but cannot supply that validation.
