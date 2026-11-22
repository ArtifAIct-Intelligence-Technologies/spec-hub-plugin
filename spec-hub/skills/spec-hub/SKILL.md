---
name: spec-hub
description: Use whenever the work touches a business rule, a requirement, a user story, an open question to the PO, a change request (CR), or "how is X supposed to work" in any feature the team builds. Read Spec Hub before writing code, tests, tickets or answers, and cite rule codes like AB-12. Also use for "what changed", "who decided", "is this decided yet".
---

# Spec Hub: the one place the team's spec lives

Spec Hub (https://spec.artifaict.team) holds the current spec of every Epic. If it is not in Spec Hub, it is
not decided. Your Spec Hub MCP reads it with the rights of the person who made the key: you see exactly what
they see, nothing more.

## Language

Reply in the language the person writes in; people on one team may prefer Thai or English. In Thai,
address the person as "คุณ". Keep tech terms, identifiers, file names and error strings in English.
Text other people will read (PR, ticket, comment) follows the team's language rule from `team_rules`.

## Your organization's own rules

This plugin knows how to use Spec Hub, not how your organization builds software. Architecture
conventions, ticket and branch formats, Jira workflow, deploy steps, network allowlists and the like are
team rules on Spec Hub. Call `team_rules` (with the repo, branch and stage when you have them) before you
write code, open a ticket, cut a branch, open or review a PR, or deploy, and follow every rule it
returns; cite its code. A team rule beats any habit or general advice in these skills.

## When Spec Hub cannot be reached

If the Spec Hub MCP is missing, fails, or asks to sign in again, stop and tell the person before anything else:
"Spec Hub MCP ใช้ไม่ได้ (<the error>) พิมพ์ /mcp เลือก spec-hub แล้วล็อกอินใหม่ แล้วบอกให้ทำต่อ".
Do not answer about rules, plans or status from local files, earlier chat or memory in its place, and do not
edit plan or spec files while it is down. Local copies can be behind the web. When the person asks where an
answer came from, name the tools you called (`search_spec`, `get_rule`, ...) and the rule links.

## Before you answer, code, test or plan

1. **Search first.** `search_spec` with the words the person used (any language the spec is written in). If the Epic is
   unclear, `list_epics`.
2. **Read the rule in full.** `get_rule` for each code you rely on. Search snippets and list rows are cut at
   500 characters; never build on a cut text.
3. **Cite.** Every business rule you use in code, a test, a ticket, a plan or an answer names its code
   (`AB-12`) and its link (the `url` field). No code to cite means it is not decided.
4. **Not decided?** `get_rule` and `get_story` list the `open_questions` about them; read those first.
   Otherwise look for one: `list_rules` with `kind: question`. If one exists, say so and
   name it (`OQ-12`). If none exists, tell the person it needs a question to the PO; do not invent the rule.
5. **Check it is current.** `rule_history` shows how a rule changed and why. Only the current text counts;
   history is for understanding, never for "how it works now".

## Reading the rest

| Need | Tool |
| --- | --- |
| A user story with AC and tasks | `get_story` |
| Discussion, answers from the PO, edge cases | `get_thread` |
| Overview, flows, design notes | `list_docs`, then `get_doc` |
| What changed together and who decided | `list_crs` |
| The person's own cards (Local Board) | `my_cards`, then `get_card` |
| Team boards | `team_board` |
| A Jira ticket, the person's sprint, JQL | `jira_get_issue`, `jira_my_issues`, `jira_search` (read only) |
| The code itself | the repo in the folder this session was opened in, or `bb_search`, `bb_tree`, `bb_file` when it is not there; skill `code` |

Lists come 20 rows a page (`page: 2` for more). An answer over 20 KB is cut; follow the `url`.

## Writing back

Specs, questions, threads, CRs and team boards are read only here. To change a rule, ask a question, or
acknowledge a CR, the person does it on Spec Hub (skill `requirement-change` says how to prepare it). Never
claim you changed the spec.

The one thing you can write is the person's own Local Board (`create_card`, `write_section`, `set_card`).
Use it as your memory across sessions; skill `local-board` says how.

## How to talk about it

- Reply in the person's language. Keep rule codes, field names and tech terms as they are.
- Quote the rule, then explain what it means for the task at hand, with a real example.
- If two rules seem to disagree, show both codes and ask; do not pick one silently.
- If a person states a rule that differs from Spec Hub, say which code says otherwise and link it.
