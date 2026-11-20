---
name: release-and-deploy
description: Use when preparing a release round or deploying the team's services: choosing the release base branch, working out what has not shipped, cherry-picking onto a release branch, merging develop into a release branch, bumping image tags in helm, opening a helm PR, adding an env var, or checking which build is live on dev, qa, uat or prod ("เตรียม release", "cherry pick", "ขึ้น uat", "deploy prod", "PR helm", "bump tag", "เพิ่ม env", "ตัวไหน live อยู่"). Extends skill `release`; read that first.
---

# Release rounds and deploys

Skill `release` covers the round as a whole: tickets that span repos ship whole, the receiver ships first,
manual steps and rollback, ENV documentation, saying what you left out. This skill is the git and helm
mechanics underneath, where most of the real incidents happened.

## 0. Team rules first (PO-97)

Before any step below, call `team_rules` with the repo, the release or env branch, and the stage
(for example DEV, QA, UAT, Prod). Rules there cover your environments, deploy branch names, reviewers,
image builds, network allowlists, manual scripts and working hours. Follow each one, cite its code in the helm PR, and name any you could
not meet. A team rule beats this skill; when they disagree, follow the rule and tell the person.

## 1. Pick the base by date, not by name

```bash
git fetch --prune
git for-each-ref --sort=-committerdate \
  --format='%(committerdate:short) %(refname:short)' 'refs/remotes/origin/release/*'
```

Take the top row. Branch names lie: a branch dated later in its name can hold older commits, and a
`-fix` suffix can be newer than the name it extends. Fetch every repo first; yesterday's local refs give a confidently wrong
delta.

## 2. Compute the delta by patch-id, not by sha

`git log base..develop` over-counts: a commit cherry-picked mid-round has a new sha and reappears as
"not shipped". Compare `git patch-id --stable` of each develop commit against those already on the base.
On one round this cut the list by a third. If a teammate says "that one already shipped", re-check by patch-id.

## 3. How it lands

- **The whole delta ships:** merge `develop` into `release/*`. Nothing gets missed.
- **Some of it is held:** cherry-pick only what ships.
- **Into `release/*`, use a merge commit, never squash.** Squash breaks `--is-ancestor`, so tools report
  shipped work as missing and the next merge invents conflicts. Ordinary PRs into develop may squash.
- **Ask PR or direct push** before landing anything on a release branch.

## 4. Verify a cherry-pick before pushing

In a fresh worktree from `origin/release/<round>`, with `behind=0` checked first, show three greens: no
conflict, the repo's own tests, the repo's own build. Then compare content, not shas:
`git diff origin/develop origin/release/<round> --stat`. The cherry-picked commit has a new sha, so an
ancestor check says no; that is expected.

**Conflicts after a squash-merged PR:** the merge base sits before the squash, so both sides look edited.
Save your side (`git show HEAD:<file>`), take it, `diff` it against the saved copy, and check
`git diff origin/develop --stat` is the same delta as before. For test files both sides appended to, take
each half from git and splice; never retype.

## 5. Before opening any helm PR

A helm PR merges seconds after approval. There is no window to catch a mistake afterwards.

- **The deployed state lives on the env's own branch** of the helm repo. Read
  `git show origin/<env>:<path>/value-<env>.yml`; the file on the editing branch can be months stale. It
  once produced a false "335 commits behind" alarm.
- **Fetch every repo at the moment you open the PR.** A survey taken ten minutes earlier missed a backend
  PR merged in between, and QA got `GRAPHQL_VALIDATION_FAILED` until the other half went up.
- **Group by ticket, not by repo.** Each repo can look fine while a ticket is half-deployed.
- **Read the tag from the pipeline that built the commit**, never from memory. Then check it the other
  way round: the sha inside the tag equals the branch HEAD you meant to ship.
- **An image tag exists only after its build step completes.** Some pipelines build the production image
  in a separate manual step (see `team_rules`); open the PR only after it completes, never write a
  predicted tag, or the pod will `ImagePullBackOff`.
- **A failed pipeline is not automatically useless.** Open the steps: a failed rollout after a green image
  push means the image exists.
- **Before merging, `git diff --name-only origin/<env> origin/<branch>`** lists only your files. Extra
  files mean the env moved; merge `origin/<env>` in first or you downgrade someone else.
- **Say what you left out** in the PR body, and why.

## 6. Env vars

- **A new ENV rides the PR that bumps that env's tag.** Otherwise the pod runs on a code fallback and
  nobody can tell "read the ENV" from "fell back". Exceptions: a fix to a wrong value, one forgotten last
  round, and dev, whose tag never changes.
- **Copy the format from the same key on the same env in another service**, never from the same service
  on another env; that copies one service's bug into a second env. Quote booleans: `value: "true"`.
- **Fallbacks fail silently.** A missing URL that falls back to a stub returns empty lists and no error;
  a missing feature flag quietly disables a rule. Find every read site and write what breaks if unset.
- **Build-time variables (for example Next.js `NEXT_PUBLIC_*`) are inlined into the bundle.** Runtime env
  does not change them. If a deployed frontend behaves as if a flag is off, read the build step's secret
  fetch first; it can fail without failing the pipeline.
- **Shared secrets that must match** (caller key = receiver key): name each pair in the deploy checklist
  and have the Vault owner compare them. Pods start fine with a mismatch; the first customer payment fails.

## 7. Network, branch names and reviewers

Which paths need an allowlist at the edge, how deploy branches are named per env, who reviews a deploy PR
and when environments are switched off are team rules. Read them with `team_rules` for the repo, branch
and stage, and treat a missing allowlist request like a missing ENV: a release blocker.

- **Pass reviewers when you create the PR** if deploy PRs merge on approval; adding them afterwards fails
  because the PR is already merged.
- Cut the branch from the env branch and check `behind=0` in the same command that edits the file.
- Never take a round number from today's date.

## 8. After the merge: which build is live

- **"Deployed" is not evidence.** Find the rollout step of the pipeline for your commit and compare its
  finish time with when you test. Know which pipeline rolls out to each env; PR pipelines usually do not.
- **On dev the last rollout to finish wins.** Several PRs merged together run several pipelines pushing
  the same tag; an older build that finished later once replaced the one containing all three tickets.
- **Check the env is up before calling a failure a bug.** If non-prod envs are switched off outside working
  hours (`team_rules`), a merge after shutdown never rolls out; restart that service when it is back, then
  check the pod runs the newest sha.
- **Release documents state only what you checked just now**: tag from the env branch, ancestry against
  the image's sha, ENV present in values. Keep three states apart: merged to develop, in the image,
  deployed.
