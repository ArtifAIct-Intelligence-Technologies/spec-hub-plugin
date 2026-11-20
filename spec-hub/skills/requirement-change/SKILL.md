---
name: requirement-change
description: Use when someone brings a new or changed requirement, a PO answer, a decision from a meeting or chat, or says "PO บอกว่า", "เปลี่ยนเป็น", "ต้องการให้", "แก้ requirement", even spread over several messages with links or screenshots. Turns it into an impact-checked change ready to record in Spec Hub, without inventing rules.
---

# A requirement changed: prepare it for Spec Hub

Spec Hub keeps one current line per rule and a history of every change. A change that only lives in chat is
lost. Your job is to turn what the person told you into a change someone can decide on and record.

## 1. Gather everything first

The story may arrive over many messages, with links and images. Collect it before analysing. Read each link
you can open. For a link you cannot open (it needs a login, like Figma or a private page), ask the person
for a screenshot or the text. For an image, describe what you read from it and the numbers you measured, so
the person can correct you.

## 2. Find what it touches

`search_spec` for every term, then `get_rule` on each hit. Classify each point:

- **change to `<code>`**: a rule already covers it. It is a change, not a new rule.
- **clarification of `<code>`**: the rule stands; the wording needs to be clearer.
- **new**: nothing covers it.
- **answer to `OQ-n`**: it settles an open question.

## 3. Write the impact, point by point

For each point:

```
What changes   <code>: <current text> → <proposed text>
Affects        other rules, stories, tickets, code or data already built, envs it is already on
Who            our team, other teams, merchants, customers, PO
Options        ก. ... result ...   ข. ... result ...
Recommend      ... because ...
```

Read the current text with `get_rule`; never paraphrase it from memory. If something is missing to decide,
write it as a question to the PO with the context and a real use case, not just "what should happen?".

## 4. Hand it over

Show the person the whole set and let them correct it. Then they record it in Spec Hub:

- Post it in the thread of the rule it changes (or the Epic's question), and press **ลงสเปก**. It goes into
  the queue and the spec is updated with the decider's name, why, and the impact.
- Every recorded change shows on the CR board so the team can acknowledge it or raise a concern.

You cannot write the spec yourself. Do not say the spec is updated until the person sees the new text on
the rule's page. While it waits, keep the prepared change on the person's card (`write_section`, kind Note)
so it is not lost when the session ends.
