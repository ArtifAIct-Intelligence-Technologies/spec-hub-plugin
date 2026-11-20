---
name: release
description: Use when preparing or checking a release or deploy of the team's services: what ships in a round, what must ship together, steps before and after deploy, ENV variables to add, rollback, or "ticket นี้ขึ้น env ไหนแล้ว". Uses Spec Hub release and ENV pages as the record.
---

# Releasing with Spec Hub as the record

Spec Hub tracks, per ticket: which commits in which repos, which release round, what must ship with it, what
to do before and after deploy, which env it is on and with which image tag, and how to roll back. ENV
variables each have a page: what it is for, why it exists, the default, what each setting does, what breaks
if it is unset, and the value per env. Secret values are never written there.

## Team rules first (PO-97)

For every repo in the round call `team_rules` with the repo, the release branch and each stage it goes
to. Put what they ask for into the round: allowlist requests, manual steps, reviewers, images. Cite the
codes so the person can check them on Spec Hub (กฎทีม).

## Before a round

1. List every ticket in the round and, for each, every repo it touched. **A ticket that spans repos ships
   whole or not at all**; a half-shipped change breaks the contract between services.
2. Check what must go together (a new field the receiver must accept first, a migration before the code
   that uses it). The receiver ships first.
3. Collect the manual steps for before and after deploy, and the rollback for each.
4. For every new or changed ENV: its documentation must exist, with the purpose and what breaks if unset.
   Copy the format from the same variable in another service on the same env.
5. Read the rules each ticket implements (`get_rule`) and make sure what ships matches the current text.

## After

Record what shipped and where on Spec Hub (Release page). If anything was left out, say what and why;
silence reads as an oversight.

Never state that something is deployed without evidence from the pipeline or the env itself.

## Filling the round on Spec Hub (PO-98)

The round page on Spec Hub is the record. Read it with `list_rounds` and `get_round` before adding
anything, so you never add what is already there. Add drafts with `release_draft`; each item needs
`ai_from`, the place you read it from. Your drafts wait for a PO or Tech Lead to confirm them on the
web, and an unconfirmed step cannot be ticked. Only a PO or Tech Lead of a joined team can add drafts;
if `release_draft` says you cannot plan the round, tell the person instead.

Where each part comes from. Never invent an item; if you did not read it, do not add it.
- **Services:** compare the image tags in the helm values of the target env with the one below it
  (UAT against QA, Prod against UAT). Each changed service is a `service` item with its tags, the helm
  PR links, the tickets and the commits. A repo already in the round only gets its empty fields filled.
- **Vault and ENV:** new or changed ENV keys in the same helm diff. A key read from Vault becomes a
  `before` step: where (the Vault path), what to put, and what must match (paired keys).
- **Allowlists:** new routes in the diff, checked against `team_rules` of the network category. Each
  rule that applies becomes a `before` step that cites the rule code in `ai_from`.
- **Manual scripts and data:** migrations and seed scripts in the commits become `before` or `after`
  steps with the exact command, and a `rollback` or `irreversible` item for each.
- **Release note:** one `note` per change, from the commits, tickets and Epics of the round. The tech
  edition names the service and ticket; the user edition says only what a user would notice, in plain
  words in the team's language, and leaves out internal changes.

After the deploy, compare what runs on each env (image tag, pod restarts, the numbers the after steps
expect) with the plan and write what you saw with `release_check` on that step. Do not tick steps;
the person ticks them on the web after reading your check.
