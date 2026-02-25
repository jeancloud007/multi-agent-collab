# GitHub Operations Skill

**Name:** github-ops
**Description:** Common GitHub CLI workflows for AI agents — issues, PRs, repos, and CI/CD.

---

## Prerequisites

- `gh` CLI installed and authenticated
- Test with: `gh auth status`

---

## Core Operations

### 1. Repository Management

```bash
# List repos
gh repo list [owner] --limit 20

# Create repo
gh repo create [name] --public --description "Description"

# Fork repo
gh repo fork [owner/repo] --clone=false

# Clone repo
gh repo clone [owner/repo]
```

### 2. Issues

```bash
# List issues
gh issue list --repo [owner/repo] --state open

# Create issue
gh issue create --repo [owner/repo] --title "Title" --body "Body"

# View issue
gh issue view [number] --repo [owner/repo]

# Close issue
gh issue close [number] --repo [owner/repo]

# Add labels
gh issue edit [number] --repo [owner/repo] --add-label "bug,priority"
```

### 3. Pull Requests

```bash
# List PRs
gh pr list --repo [owner/repo]

# Create PR
gh pr create --repo [owner/repo] --title "Title" --body "Body" --base main

# View PR
gh pr view [number] --repo [owner/repo]

# Merge PR
gh pr merge [number] --repo [owner/repo] --merge

# Review PR
gh pr review [number] --repo [owner/repo] --approve
gh pr review [number] --repo [owner/repo] --request-changes --body "Feedback"
```

### 4. CI/CD (Actions)

```bash
# List workflow runs
gh run list --repo [owner/repo]

# View run details
gh run view [run-id] --repo [owner/repo]

# Watch run in progress
gh run watch [run-id] --repo [owner/repo]

# Re-run failed jobs
gh run rerun [run-id] --repo [owner/repo] --failed
```

### 5. Releases

```bash
# List releases
gh release list --repo [owner/repo]

# Create release
gh release create [tag] --repo [owner/repo] --title "Title" --notes "Notes"

# Download release assets
gh release download [tag] --repo [owner/repo]
```

---

## Common Patterns

### Create Issue from Error Log
```bash
ERROR_MSG="Build failed: missing dependency"
gh issue create --repo [owner/repo] \
  --title "CI: $ERROR_MSG" \
  --body "Automated issue from CI failure.\n\nError: $ERROR_MSG\n\nRun: [link]" \
  --label "bug,ci"
```

### Fork → Branch → PR Workflow
```bash
gh repo fork [owner/repo] --clone=true
cd [repo]
git checkout -b feature/my-change
# ... make changes ...
git add -A && git commit -m "Add feature"
git push origin feature/my-change
gh pr create --title "Add feature" --body "Description"
```

### Check PR Status Before Merge
```bash
gh pr checks [number] --repo [owner/repo]
# Wait for all checks to pass, then:
gh pr merge [number] --repo [owner/repo] --merge
```

---

## Gotchas

1. **Rate limits:** GitHub API has rate limits. Space out bulk operations.
2. **Auth scope:** Some operations need specific scopes. Check with `gh auth status`.
3. **Default branch:** Not always `main` — check with `gh repo view --json defaultBranchRef`.
4. **Org permissions:** Forking org repos may require additional permissions.

---

## See Also

- [GitHub CLI Manual](https://cli.github.com/manual/)
- `/shared/learnings/` for specific patterns discovered in practice
