---
name: ship-and-review
description: Use for the everyday loop of shipping a change and for reviewing one: opening a Jira ticket, cutting a branch, writing a commit, opening or updating a PR, posting comments, answering review, reviewing someone's PR, or deciding if a PR is ready to merge ("เปิดตั๋ว", "เปิด branch", "commit", "เปิด PR", "ตอบรีวิว", "review PR", "พร้อม merge ไหม"). Covers the steps that cannot be undone later.
---

# Shipping and reviewing a change

## 0. Team rules first (PO-97)

The leads keep the team's own rules on Spec Hub (กฎทีม): branch names, PR text, merge style, reviewers,
network allowlists and more. Before you cut a branch, open a PR, merge, or answer review, call
`team_rules` with the repo, the branch (the one you create, or the one you merge into) and the stage if
it heads to an env. Follow every rule it returns and cite its code in the PR or in what you tell the
person (e.g. "per GIT-01"). A team rule beats this skill and any habit; if they disagree, follow the rule
and tell the person. When `what_changed` reports kind `teamrule`, call `team_rules` again.

## 1. Ticket before branch

Get the Jira key before `git checkout -b`. Bitbucket cannot change the source branch of an open PR, so a
branch without the key means a new branch, an amended commit, a second PR and a declined first one, for a
diff that never changed.

- Read the ticket yourself (skill `code`). Business rules come from Spec Hub with their codes.
- **Ticket type, where it hangs (story, subtask, epic), title shape, and which statuses you may move it
  to** are team rules: read `team_rules` before you open or move a ticket. Never move, comment on or pick
  up a teammate's ticket.
- **Jira bodies are markdown** (`##`, `|`, `-`, backticks). Old wiki markup (`h3.`, `||`) shows as raw text.
- **Decided but nowhere to store it:** when a rule is decided and the contract or table cannot hold it
  yet, open the ticket under the epic the same day. A control shipped disabled cites that ticket.
- Before proposing a ticket as next work, check its code is not already on develop (skill `investigate`).

## 2. Branch, commit, PR

- **One ticket or branch, one worktree (PO-121).** Never switch branches in the person's main checkout; they
  may have work in progress there. Create it under the session folder, never in `/tmp`:
  ```bash
  git -C <repo> fetch -q origin
  git -C <repo> worktree add -b <branch> "<session folder>/.worktrees/<repo>-<KEY>-<desc>" origin/<base>
  ```
  The path is `<session folder>/.worktrees/<repo>-<KEY>-<desc>`. If the session folder is itself a git repo,
  add `.worktrees/` to its `.git/info/exclude` (local, never committed).
- **Clean up when the work ends** (PR merged, or the person says done), and only what you created:
  `git worktree remove <path>` then `git worktree prune`; stop the dev servers, watchers and containers you
  started; delete temporary files; delete the local branch only when it is pushed and merged, never a remote
  branch. Check first, delete in a separate command, and never `rm -rf` through a symlink (remove a linked
  `node_modules` link first). The plugin's hook lists what is still in `.worktrees` at session start and when
  a card changes status: act on it, ask the person about anything that is not yours, and report what you
  removed and what you kept.

- Branch and commit names follow the team's rules (`team_rules` with the repo). Without a rule, use
  `<type>/<KEY>-short-desc` and `<type>: <KEY> — <description>`.
- **One PR, one topic.** Refactors go in their own commit; no unrelated files. It keeps cherry-picks clean.
- **Default to zero comments in code.** Before `git add`, read the diff as a reviewer and delete comments
  that narrate the code, ticket or date references, and "mirrors X" notes that rot. Keep one line only
  where a reader would otherwise be confused, and only about why.
- **Worktree with a symlinked dependency folder** (`node_modules`): never `git add -A` or `git add .`; the
  symlink gets committed and CI's install fails. Stage explicit paths.
- **Never delete the source branch** after merge, and do not tick "close source branch". One branch often
  feeds two PRs (release and develop), and the branch is the record.
- **Merging into a release branch: a merge commit, never squash.** Squash breaks ancestry checks and invents
  conflicts on the next merge. Pick it in the merge dialog. Ordinary PRs into develop may squash as usual.
- **Landing on a release or other deploy-bound branch:** ask whether it goes by PR or direct push.
  Approval of what to land is not approval of how. Deploy config changes always go by PR.

## 3. Prove it landed

- **After a push**, check the content reached the remote:
  ```bash
  git fetch origin <branch> -q
  git log origin/develop..origin/<branch> --oneline   # not empty
  git diff origin/develop origin/<branch> --stat      # the files you meant
  ```
  A push succeeds with zero commits if the commit step was skipped.
- **Before pushing more commits to a PR, check it is still open.** A merged PR ignores them silently.
- "I edited the file" is not done. Done is the output: tests, build, and the change seen running.

## 4. Writing where teammates read

How to write PR titles and descriptions, review comments, replies, tickets and status text: skill
`human-writing` (the one place for these rules). Mechanics that are about tools, not wording:

- **Answering review on your own PR:** read every comment with `bb_pr_comments` (file, line, replies, resolved). Do not use
  `pr_take` or `pr_review_url` for your own PR; those put it in your review queue as a reviewer.
- **Every PR has a ticket key** in its title, `<type>: <KEY> — <what it does>`, like the commit. No key, no PR:
  ask for the ticket first.
- **No local paths** to private notes in tickets or PRs. Quote the content instead.
- **Write drafts with a file tool or a quoted heredoc** (`<<'EOF'`). An unquoted heredoc runs backtick
  spans as commands and drops them. Read the whole draft before posting, and read back what you posted.
- **Steps others follow** (manual steps, runbooks) use tools the whole team has (see `team_rules`).
  Never a script that exists only on one machine.

## 5. Reviewing a PR

- **Read the requirement before calling something a bug.** Open the spec and the code comments; decide
  whether the code is wrong, the spec is out of date, or the gap is deliberate. Cite the rule code or
  `file:line`. Reviewers see code, not the business.
- **Reproduce each finding** before you post it. Severity drops when you cannot show a broken case.
- **Pick lenses by risk:** auth or id lookup, money, migrations, new tests (do they go red if the code
  breaks), cross-repo contracts (DTO, enum, envelope), blast radius (ENV, deploy order, files from
  other work in the diff).
- **Trace every user-visible constant** (labels, empty-cell text, placeholders) to a spec line or repo
  convention. Unsourced ones go back to the author.
- **Before approving:** the PR head pipeline is green, and the review bot's comments on the current head
  are read. An "Important" bot finding is verified and fixed or answered first.
- **Before writing "please verify",** `git grep` the target repo for the value. If the answer is
  lookupable, decide. Comments are for real trade-offs.
- A reviewer ends at the comment. Do not offer to make the fix; the author does.

## 6. Answering review on your PR

- **Run it before you argue "no change needed".** The costliest wrong answer in one round was an
  untested claim about a library that, with a new panic, crash-looped every pod.
- **After a fix, ask what else it touches** and run the tests for that area. Fixes tend to add mechanisms
  that collide with old ones; most later review rounds were caused by earlier fixes.
- **If a review asks whether something holds somewhere, check every place.** One of two call sites was
  fixed and the other shipped broken.
- **A finding the reviewer marks as out of reach** becomes a new ticket, not more rounds on this PR.
- **"Ready to merge?"** gets a yes or a no with the reason.
- **Big or risky specs** (several repos, schema, auth or money, multi-phase) get a review of the spec
  itself before code: architecture, security, AC coverage. Every such review here found real blockers.
