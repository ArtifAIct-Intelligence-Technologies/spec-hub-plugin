---
name: human-writing
description: Use whenever you write text a teammate will read, in Thai or English, before you send or post it. That means PR titles and descriptions, PR review comments and replies, Jira ticket text, requirement or spec text, commit bodies, and status updates in chat ("เขียน PR", "เขียน description", "ตอบรีวิว", "เขียนตั๋ว", "สรุปสถานะ", "อัปเดตทีม"). Makes the text read like a teammate wrote it, not an AI.
---

# Write like a teammate

People on the team spot AI text in a few words, and then they trust the rest less. Your job is text a
busy engineer reads once and acts on. Write people-facing prose in the team's language (a team rule;
without one, the language the reader uses). Tech terms, identifiers, file names,
ENV names and error strings stay in English, exactly as they appear in code.

## 1. Core rules

1. **Say the thing first.** The first line answers "what happened" or "what do you need from me".
2. **Short sentences.** One idea each. In Thai, which has no full stop, so end the idea and start a new line or
   leave a space; do not chain clauses with ซึ่ง and โดย.
3. **Concrete over abstract.** Numbers, `file:line`, ticket key, rule code, the input that breaks, the
   command and its output. "ช้า" is a claim; "p95 1.8s จาก 300ms" is a fact.
4. **Name who does what.** Active voice. "ผมแก้ `X`" or "`X` คืน 404", not "ได้รับการแก้ไข".
5. **Keep tech terms in English.** Never paraphrase `header`, `ENV`, `migration`, `AC`, `DoD` into Thai.
6. **Match the register of the team.** Polite, plain, between peers. Not a government letter, not marketing.
   Look at a recent ticket or PR the team wrote and match it.
7. **Write as the account holder.** Comments post under a person's name. Use first person; in Thai use
   their own particle (ครับ or ค่ะ) once or twice per message, not on every sentence.
8. **No filler, no hedging, no hype.** If a word does not change what the reader does, cut it.
9. **Structure only when it helps.** A three-line PR needs no headings. Use a list for real parallel items,
   a table for data that lines up. Never headings over one-line sections.
10. **Do not invent.** No test you did not run, no rule code you did not read, no number you did not see.
    If you do not know, write the open question.
11. **House formatting.** Markdown, never Jira wiki markup. A blank line before every table. Never the
    section sign or the middle dot as a separator; break the line instead.

## 2. Top AI tells and the fix

| Tell | Fix |
| --- | --- |
| Inflated importance: "สำคัญอย่างยิ่ง", "pivotal", "a testament to" | Say what it changes, with a number |
| Hype and AI words: "ยกระดับ", "ราบรื่น", "ครอบคลุม", "seamless", "robust", "delve", "leverage" | Delete, or state the measurable thing in a plain word |
| "ไม่เพียงแต่...แต่ยัง", "not only X but also Y", "it's not X, it's Y" | Say Y. Drop the strawman X |
| Rule of three: three adjectives or three benefits by reflex | Keep the one that is true and matters |
| Vague attribution: "หลายฝ่ายเห็นว่า", "experts say" | Name the source or drop the claim |
| Trailing "-ing" commentary: ", highlighting the need for..." | Delete it, or make it its own sentence with a fact |
| "serves as", "features", "boasts" instead of "is" / "has" | Use is, has, เป็น, มี |
| Thai filler verbs: "ทำการแก้ไข", "ดำเนินการตรวจสอบ" | The verb alone: แก้, ตรวจ |
| "มีการ", "ได้มีการ", "ในการที่จะ", "มีความ + adj" | Drop them: "ประชุมแล้ว", "จะ", "สำคัญ" |
| Chains of ซึ่ง / โดย / ที่ copying English relative clauses | Split into two sentences |
| "ถูก" / "ได้รับการ" passive for normal events | Active with the actor, or "แก้แล้ว" |
| การ/ความ noun stacks: "การดำเนินการปรับปรุงการแสดงผล" | Verb: "แก้หน้าแสดงผล" |
| Stiff register: "ท่าน", "ดังกล่าว", "ทั้งนี้", "อนึ่ง" | Teammate words: คุณ, อันนี้, ตัวนี้ |
| Every paragraph opens with "นอกจากนี้", "อย่างไรก็ตาม", "Additionally" | Start with the subject |
| Hedging: "อาจจะ...ได้ในบางกรณี", "it might potentially" | Say what you know, mark what you do not |
| Sycophancy: "คำถามที่ดีมาก", "Great catch!", "You're absolutely right" | Start with the answer |
| Closers and recaps: "หวังว่าจะเป็นประโยชน์", "หากมีข้อสงสัย...", "สรุปคือ...", "Let me know if" | End when the content ends |
| Emoji headings, Title Case headings, bold label on every bullet | Plain sentence-case headings, few of them |
| Em dash in every sentence, colon before every list, English comma before "และ" | Full stop, new line, or a space |
| Synonym cycling to avoid repeating a word (cart, ตะกร้า, basket) | Repeat the same term |

## 3. PR title and description

Title: same shape as the commit, `<type>: <KEY> — <what it does>` (the dash is convention, not a tell),
in English, imperative, specific. Not "Fix bug" or "Cart improvements".
Every PR has a ticket key; without one, ask for the ticket before opening the PR.

**One template per PR (team rule PR-03).** Pick the structure before you write:

1. Call `team_rules` for the repo. If a rule there gives a PR template for this repo or team, that template is the
   structure: keep its headings and order, and put the facts below under them.
2. If there is none, use the order below.
3. A template from the person's own notes, another tool or a previous PR is not a team template. Never paste it under or
   above this one. If the person wants their own template, it is added to the team rules first.

Never send two sets of headings, a heading twice, or empty placeholders ("N/A", "-", "TBD"). `pr_open` refuses a
description whose headings repeat.

Whatever the structure, the body holds these facts, leaving out any part that is empty (write "ไม่มี" only for risk lines):

1. What and why in one to three lines. The user-visible problem, then the cause.
2. Ticket key and the spec rule codes it follows.
3. What changed, one line per repo or area, with `file:line` where it helps.
4. How you tested, with real evidence: the command and its result, the env and the steps, screenshots
   for UI (desktop and mobile width when the screen has both).
5. Risk: migration, new ENV, what must ship together and in which order, rollback.
6. What you want the reviewer to look at.

Good:

```
fix: ABC-1234 — Keep voucher after quantity change

ลูกค้าเปลี่ยนจำนวนสินค้าในตะกร้าแล้ว voucher ที่เลือกไว้หลุด ต้องเลือกใหม่ทุกครั้ง (CT-12)
สาเหตุ: `updateQuantity` สร้าง cart ใหม่แทนการ patch เลยทิ้ง `appliedVoucherId`

แก้
- cart-service `cart.service.ts:210` patch เฉพาะ `items`
- เพิ่ม test เปลี่ยนจำนวน 2 รอบแล้ว voucher ยังอยู่ (แดงก่อนแก้ เขียวหลังแก้)

ทดสอบ
- `yarn jest cart.service` ผ่าน 48/48
- dev: เปลี่ยนจาก 1 เป็น 3 ชิ้น voucher ยังอยู่ ลด 50 บาทเท่าเดิม (รูปแนบ)

ไม่มี migration ไม่มี ENV ใหม่ ship เดี่ยวได้ ถอยด้วย revert
ฝากดู `cart.service.ts:205-230` ว่าชนกับตอน merge cart หลัง login ไหมครับ
```

Bad, and why:

```
## 🚀 Summary
PR นี้เป็นการดำเนินการแก้ไขปัญหาที่มีความสำคัญอย่างยิ่ง ซึ่งส่งผลกระทบต่อประสบการณ์ของผู้ใช้งาน
โดยได้ทำการปรับปรุงกลไกการจัดการตะกร้าสินค้าให้มีประสิทธิภาพและความเสถียรมากยิ่งขึ้น
## ✅ Testing
- **การทดสอบ:** ได้มีการทดสอบอย่างครอบคลุมในทุกกรณี
## 🎯 สรุป
การเปลี่ยนแปลงนี้ไม่เพียงแต่แก้ไขปัญหา แต่ยังยกระดับความน่าเชื่อถือของระบบโดยรวม
```

It never says what broke, where, or how it was proven, and it stacks tells: emoji headings, ทำการ,
ได้มีการ, a ซึ่ง-โดย chain, "ครอบคลุม" with no test named, "ไม่เพียงแต่", a recap. Every good line is actionable.

## 4. Review comments and replies

One finding per comment, on the line. Shape: label, what, why (the case that breaks, rule code,
`file:line`), then a concrete fix or a precise question. Labels: `blocker`, `major`, `minor`, `nit`,
`question`. About the code, never the person. No praise padding, no recap of the diff.

```
major: ถ้า `items` ว่าง `reduce` ไม่มีค่าเริ่ม จะ throw ตอนลูกค้าลบชิ้นสุดท้าย ใส่ `0` เป็นค่าเริ่มก็พอครับ
question: ตรงนี้เช็ค `storeId` ของคนเรียกไหม ถ้าไม่ คนอื่นส่ง id ร้านเรามาแก้ได้ (IDOR)
nit: ชื่อ `data2` ไม่บอกอะไร เป็น `paidOrders` ไหม ไม่แก้ก็ merge ได้
```

Reply to each comment in its thread with one of three shapes, then stop:

```
แก้แล้วใน `a1b2c3d` เพิ่ม test เคส `[]` ด้วยครับ
ขอไม่แก้ครับ CT-12 ให้ปัดเศษตอนจ่าย ถ้าปัดตรงนี้ order หลายร้านยอดเพี้ยน 1 สตางค์ (test `rounding.spec.ts:40`)
ถามกลับครับ ถ้าเปลี่ยนเป็น `findMany` แล้ว order ที่ยกเลิกต้องนับไหม สเปกยังไม่พูดถึง
```

No "ขอบคุณสำหรับคำแนะนำที่ดีมากครับ", no paragraph defending the old choice. Run the check before
you write "no change needed".

## 5. Jira tickets and requirement text

Title and body language follow the team's rules (`team_rules`). Without one: `[<repo>] <English
description>`, body in markdown in the team's language.

- Who has the problem, what they cannot do now, why it matters (a real case or a number).
- AC as outcomes someone can see or measure, one per line, each with its rule code. Not "ระบบทำงานได้ดี".
- Anything undecided is marked as an open question with its code, never filled with a guess.
- Out of scope, when someone would otherwise assume it is in.

```
ร้านค้าที่มี 2 สาขาเห็น order ของอีกสาขาในหน้ารายการ เพราะ query กรองแค่ `merchantId`

AC
- ผู้ใช้สาขา A เปิดหน้า order เห็นเฉพาะ order ของสาขา A (MC-31)
- เปิด `/orders/<id>` ของสาขา B ได้ 404 ไม่ใช่ 403 (MC-32)
- order ที่สร้างก่อนมีสาขา แสดงที่สาขาไหน: รอคำตอบ OQ-7
```

Requirement text: one current statement per rule, present tense, numbers and units. No "should
ideally", no "เพื่อประสบการณ์ที่ดี". Write the exception itself, not "บางกรณี".

## 6. Status updates in chat

Lead with what the reader must do or decide, then what is blocked and by whom, then what just happened.
One fact per line. Numbers and links, not adjectives. If the person or team has a set format, use it.
No "อัปเดตความคืบหน้าดังนี้ครับ" opener, no "หากมีข้อสงสัยสอบถามได้เลยครับ" closer.

```
ต้องการ: ขอ approve PR #212 ก่อน 15:00 จะได้ขึ้น qa รอบนี้
ติด: ENV `PAYMENT_TIMEOUT_MS` บน qa ยังไม่มี รอ infra
เสร็จ: merge #210 แล้ว dev build ผ่าน เปิดหน้าตะกร้าบน dev ได้ปกติ
```

## 7. Before you send

1. **Read it aloud** in your head as the teammate who gets it. Would a person on the team say it this way
   in chat? If a sentence sounds like an announcement, rewrite it the way you would say it.
2. **First line test.** Could the reader stop after line one and know what this is and what they need to do?
3. **Cut 20%.** Delete openers, recaps, adjectives, "ทำการ", "ได้มีการ", "ซึ่ง" chains, any heading over a
   single line, and any sentence that repeats another.
4. **Scan the tells table** in section 2. Fix every hit, Thai and English.
5. **Every claim has evidence.** Each "tested", "fixed", "no impact" points to a command, a line or a
   screenshot. Each rule code and ticket key was read, not remembered.
6. **Tech terms in English, spelled as in the code,** in backticks. Formatting per core rule 11.
   Read the posted text back once to check it rendered.
