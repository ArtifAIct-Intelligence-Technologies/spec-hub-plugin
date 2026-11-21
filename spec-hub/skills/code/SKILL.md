---
name: code
description: Use whenever the work needs the code itself: fixing a bug, building a ticket, reviewing a change, "โค้ดอยู่ไหน", "ทำไมพัง", "แก้ตรงนี้กระทบอะไร", "service ไหนเรียก", or reading a Jira ticket (ABC-1234) before coding. Read the code from the repos in the session folder; the Spec Hub Code Map is only an optional extra.
---

# Working on the code

The code lives in the team's Bitbucket repos, and you read it from the clones in the folder this session was opened in. Spec Hub tells
you what the code is supposed to do (skill `spec-hub`); the code tells you what it does now. Never let one stand
in for the other.

## 1. Know what the work is

- A ticket key in the chat (`ABC-1234`): read it with `jira_get_issue` before anything else. `jira_my_issues`
  lists the person's own tickets and sprint; `jira_search` takes JQL.
- These read Jira with the person's own account and change nothing. To move a ticket, comment or edit it, the
  person does it in Jira; never say you did.
- `jira_not_connected` or `jira_relink`: tell the person to press เชื่อม Jira (or เปลี่ยน Jira) on their board
  in Spec Hub, then carry on with what they can tell you. Never guess ticket content.
- Every business rule the ticket depends on comes from Spec Hub with its code (`AB-12`), not from the ticket text alone.

## 2. Read the real code

1. **Find the repo in the folder this session was opened in**, or a folder under it. Each service is its own
   git repo. Never look through other folders on the machine (the home folder, sibling project folders): they
   are not part of what the person gave you.
   - **Not there?** Stop and ask, naming the repo: where it is cloned, whether to clone it here, or whether to
     read it through Bitbucket instead (people without the repo, such as a PO, work that way). Never guess
     where a repo lives or what its code says.
2. **Make sure it is current.** `git fetch`, then read what is on the team's main branch
   (`git show origin/develop:<path>`, or `origin/main` where that is the branch). A local checkout a few hours old
   has misled people before.
3. **Do not disturb work in progress.** If `git status` shows changes you did not make, leave them alone: read
   from `origin/...` or a separate worktree, never stash, reset or check out over them.
4. **Claims that something is missing need proof.** "There is no endpoint for X" or "nobody calls Y" needs a
   search of the whole repo on the fresh main branch, including config files and the variable names in env files (never their values).
5. **Across services**, follow the real call: the client code, the route it hits, and the receiving handler and
   its DTO. Each repo builds on its own; a change in one is not visible in another until it ships.

## 3. The Code Map is optional

Spec Hub's `map_` tools (`map_search`, `map_symbol`, `map_impact`, `map_chain`, `map_service_links`,
`map_routes`) give a quick picture across a few mapped services. Use them when that saves time, then confirm
in the local code before you rely on anything they say.

- They cover only some repos, and run on one Mac. `map_offline`, a missing repo or a missing symbol is never a
  reason to stop: carry on from the local code.
- Never quote the map as the answer to "how does it work" without having read the code it points to.

## 4. Before you call it done

- Tests and build of the repo you changed, run here, with the output to show: only the tests the change can reach while you work, the full suite once before push.
- Every rule you implemented named by its code; anything not decided named by its `OQ-n`.
- What you worked out written to the person's Local Board card (skill `local-board`).
