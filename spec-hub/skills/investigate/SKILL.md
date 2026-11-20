---
name: investigate
description: Use before any claim that something is missing, broken, unused, not built, not merged or not deployed, and whenever tracing behaviour across the team's repos ("โค้ดอยู่ไหน", "ยังไม่มีใช่ไหม", "ใครเรียก endpoint นี้", "ทำไมพัง", "service ไหนรับผิดชอบ", "merge ไปยัง"). Also before sending a new value, field or body to another service. Extends skill `code`; read that first for the basics.
---

# Investigating across the repos

Skill `code` covers the basics: read the fresh main branch, leave other people's changes alone, follow the
real call across services. This skill holds the harder cases, each one learned from a wrong answer that
someone had to correct later.

## 1. Get the facts right before you trace

- **Restate the bug before you trace it.** Write the setup in one line (which option, which env, which
  order or coupon id) and ask when the report is ambiguous. A root cause built on a misread report sends
  people to fix the wrong thing.
- **A cause found only by reading code is a hypothesis.** Say so, and say what would prove it: a real
  request, a DB row, a repro.
- **Before guessing at a framework bug, read one working example** of the same thing in the same repo.
  Two PRs were once spent guessing at GraphQL argument binding while the resolver next door showed the
  right pattern.
- **Sparse tool output is a reason to check, not to explain.** If a CLI or API returns less than you
  expected, open the source UI and compare before building on it. A ticket read back at a third of its real
  length once looked like "a thin ticket"; the acceptance criteria were missing.
- **Expected values come from one query that joins everything.** Never pair rows from two result sets by
  eye. If a value you are about to report does not appear in any output you ran, you made it up.

## 2. Negative claims need three places

"It does not exist", "nobody built it", "we need a new ticket" are load-bearing. They rewrite plans and
open duplicate work. The fresh main branch alone cannot prove them: unmerged work is invisible there.

Before saying something does not exist, check all three and say which you checked:

1. **The sprint and backlog** in Jira.
2. **Every remote branch** of every repo involved: `git -C <repo> branch -r | grep -i <word>`.
   Use `git -C`, not `cd` in a loop; a failed `cd` silently searches the first repo again.
3. **The team's task docs** for that domain.

Variants of the same rule:

- **"Nobody calls this endpoint"** needs a grep across every repo with no path filter, including helm
  values and the variable names in env files (never their values). Service URLs live in env vars, so a
  `src`-only grep sees the variable and misses the path.
- **"Is this branch merged?"** Most repos squash by default, so `merge-base --is-ancestor` and
  `git log develop..branch` say "not merged" forever. Look for `Merged in <branch> (pull request #N)` on
  `origin/develop`, or read the PR state.
- **"This ticket is next work."** First run `git log origin/develop --oneline --grep=<KEY>` in every repo
  it names. Jira is moved by hand and often lags; two "To Do" tickets were once already on QA.

## 3. Do not disturb work in progress

- `UU`, `AA`, `DD` or `M` in `git status` of a repo you are only reading means someone has work in
  flight. Never `checkout --ours/--theirs`, `reset --hard`, `restore`, `stash` or `stash drop` there.
- Read with `git show origin/develop:<path>`, `git diff develop..origin/develop`, or a throwaway
  `git worktree add`.
- **Anything that moves HEAD goes in a worktree** when someone else may use the same checkout. HEAD can
  change between two of your commands; a rebase once replayed a colleague's branch.
- **Never use `git stash` while other worktrees of the repo are active.** The stash list is shared by all
  worktrees. Save a change with `git diff > x.patch` and remove it with `git apply -R x.patch`.

## 4. Loops over many repos stop on the first oddity

A loop amplifies one wrong assumption across every repo it touches. A batch once branched from a
two-year-old HEAD because `git checkout develop` failed silently and `pull` reported "Already up to date".

- Do not silence `git` inside the loop (`> /dev/null 2>&1` hides "behind by 155 commits").
- After branching and before editing, inside the loop body:
  ```bash
  behind=$(git log HEAD..origin/<primary> --oneline | wc -l)
  [ "$behind" = "0" ] || { echo "STOP: $repo behind by $behind"; exit 1; }
  ```
- On any unexpected state (checkout failed, branch missing, odd remote) stop and ask. Never fall back to
  a branch that "looks like develop".
- Fetch in parallel (`xargs -P 12`), and only the repos the question touches.

## 5. Contracts between services

Each repo's tests see only its own side. These failures are invisible until both sides run together.

- **New value on the wire** (status, warning code, type): grep every consumer for an existing value of the
  same set and add the new one to every closed list (TS enum, GraphQL enum, union, `switch` with `never`).
  A non-null GraphQL enum turns one unknown value into `data: null` for the whole response. The consumer
  ships first; write the order in the PR.
- **NestJS `registerEnumType` puts the TS enum keys on the wire**, not the values. Keys must equal what
  clients send.
- **Changed meaning of a money field** (sale vs full price, gross vs net): grep every service that reads,
  re-computes or validates it, list each with `file:line`, and ship them as one group or hold the change.
- **New or changed request body:** read the receiver's DTO and validation pipe, and diff against a body
  an existing working caller already sends. Send only fields the receiver accepts. A "safe" `false` flag
  once failed every payment because the receiver rejected the field outright.
- **A path shape no other repo uses is a defect signal.** Grep every repo for the prefix first. A route
  under a prefix the gateway guards for everyone answered 401 before reaching the service.
- **Routing and gateway conventions** (which path prefixes exist, which the gateway checks and which it
  passes through) are team rules. Call `team_rules` with the repo before adding a route, and give every
  route the gateway does not check its own guard.
- **Master data owned by another service** (zones, partners, rate tables, statuses): name the source
  service, table and column before hardcoding anything.
- **Store the upstream error code** with a failed cross-service call, not just the status. A bare
  "404" from a call with several possible causes forced a log hunt.

## 6. Real systems

- **Database errors on a real env:** a local repro proves nothing about the server. Compare read-only
  commands from a machine that reaches it, changing one variable at a time.
- **`invalid input value for enum` (22P02):** compare `enum_range` on the DB with the migration DDL before
  touching code. A migration row marked finished does not prove its DDL survived a restore.
- **Commands you hand to someone else** are tried locally in the same shape first, including a URL that
  already has a query string. Call a command read-only only after checking what it does when its target
  is missing.
- Never read secret values. Ask the owner to run the command and send the output, not the URL.
