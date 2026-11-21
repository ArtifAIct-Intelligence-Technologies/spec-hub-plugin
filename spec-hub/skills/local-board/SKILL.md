---
name: local-board
description: Use when someone works on a Jira ticket or story, wants to break work into pieces, plan their day, write AC, test cases or DoD, or says "แตกงาน", "วางแผนงาน", "ทำ checklist", "เขียน testcase", "ทำต่อจากเมื่อวาน", "ถึงไหนแล้ว". Also at the start of any session that continues earlier work. The person's Local Board cards are your memory; the chat is not.
---

# The Local Board is your memory

You forget everything when the session ends or the context is compacted. The person's Local Board does not.
Treat each card as the record of the work: what it is, the rules it follows, what was decided, what is left.
If it is not on the card, the next session will not know it, and you must not make it up.

Work lives in three layers: **Jira** is where the team's real work is tracked, the **team board** (Board Hub)
is what a team shares in Spec Hub, and the **Local Board** is private to its owner. You can write only the
person's own Local Board cards. The PO's text in Jira is never edited from here.

## Start of every session that continues work

1. `my_cards` to find the card (it also lists the board's columns), then `get_card` for the full text.
2. Continue from what the card says. If the card and the chat disagree, the card wins; ask the person.
3. Never state progress or a status you did not read from the card or hear from the person.

## Knowing when something changed (web, Jira, the PO)

The person, the PO or Jira can change things while you work: a question your card waited on gets answered, a rule
the card refers to changes, the ticket moves in Jira. Do not re-read every card to find out.

1. Call `what_changed` with the version you saw last (0 the first time) when you start, and again before you pick
   the next ticket. Keep the `version` it returns. Empty `items` means nothing changed.
2. When the Spec Hub hook adds a line saying something changed, call `what_changed` with the `since` it gives, tell
   the person in one or two lines, and only then continue.
3. An item of kind `unblocked` means a card that was waiting is ready again. Say so; do not start it unless asked.
4. When the person says a card is blocked on a question or rule, call `set_blocked` with those codes (e.g. OQ-31),
   so the owner is told when it is answered. Pass an empty list when it is no longer blocked.
5. In Claude Code the plugin hook does the version check for free. To turn it on, call `feed_token` and save the
   token as the first line of `~/.spec-hub/feed` (chmod 600) only when the person agrees. The token reads one
   number, never content.

## Breaking work down

1. **Start from the source.** `jira_get_issue` for the ticket when there is one, `get_story` for the story, `get_rule` for every rule it names. AC and tests
   come from the rules, not from guesses. No rule to cite: it is not decided (skill `requirement-change`).
   Both return `open_questions`. A test whose expected result an open question covers names that `OQ-n`
   and says "รอคำตอบ OQ-n" instead of an expected value; never pick one of the question's options.
   A gap no open question covers goes in the card's Note as a new question for the person to raise.
2. **Split by what can be finished and checked on its own**, not by layer.
3. **Write it down as you go.** `create_card` (use `parent_id` for pieces under the main card) starts every
   card with the team template. Fill every `label:` line; write `ไม่มี` when nothing applies, never leave one empty.
   - Description: the problem or goal, who gains, what is in scope and what is not.
   - Rules: the spec codes the work follows and the open questions (`OQ-n`) that touch it.
   - AC: one Given/When/Then per line, each ending with its rule code, or `รอคำตอบ OQ-n`.
   - Testcase: the normal path, each rule's edge, the empty case, the error the user sees, a walk through the
     journey with real roles, and 1440 and 375 widths when there is a screen.
   - Impact: repos and files, what must ship together, ENV, migration, risk (R0 cannot be undone: ask first;
     R1 costly to undo; R2 easy), how to roll back, and any data that leaves the team (screenshots, exports).
   - DoD: the checks this card needs (tests, which gate, which env, spec still matches).
   - Evidence: the commands you ran with their real output, screenshots, links. Empty Evidence means not done.
   - Waiting: who or what the work waits for.
   - Decisions: append only, one line per decision with who decided and the spec code (the date is added for you).
   - Note: anything else worth keeping.
4. **Check readiness before work starts.** `card_ready` lists what is missing (no rule code, an AC line with no
   code or open question, an empty Impact line). Tell the person; do not start on a card that is not ready
   unless they say so. An assumption you have not proven goes in Note as "สมมติฐาน: ..." until you prove it on
   the real system, then the proof goes in Evidence.
   - **The card is the memory the next session trusts.** Write only what you checked or what the person
     decided. A guess (where a repo lives, what a folder is for, who owns a step) never goes in Impact or
     Waiting as a fact: ask first, or label it in Note as an assumption.
5. **A ticket from a card.** When the person asks for a Jira ticket from a card, call `jira_create_from_card`
   without `confirm` and show them the preview. If the preview lists `po_stories`, the PO already opened stories
   under that epic: when one covers the card, call again with `story=<KEY>` so it becomes a Subtask under it
   (PO-74). Call with `confirm: true` only after they say yes. Ask for the epic key; never guess one. A card that
   already has a key is never created twice. When they start the work, `jira_start_work` moves the ticket and
   its story to In Progress together.
6. **Before you finish**, make sure everything worked out in the chat is on a card. Say which cards you
   wrote.

## Status

Move a card (`set_card` with `status`) only when the person tells you to, and only to a column that exists
on their board (`my_cards` lists them). Do not move cards because work "seems done". Jira stays the source
for the team's ticket status.

Everything you write shows on the card's history as done through the person's AI, with the key's name.
