# Undo log — example entries

One entry per pass, appended, never rewritten. Names below are placeholders; a
real log names real senders, which is why a real log is gitignored.

The entry has to answer three questions: what changed, what was decided by
judgement rather than by rule, and what was deliberately left alone.

---

## 2026-01-15, pass 1 (gmail-full MCP)
No filters existed. Created all 14 from `my-rules.md`, one per label group plus
the four subject rules and the two trash rules. Then labelled 180 inbox
messages, trashed 3, deleted nothing.
Breakdown: 62 Marketing, 41 Learning, 28 Finance, 20 Work, 15 Health,
9 Travel, 5 Tooling.
Judgement calls: three senders had no precedent anywhere in the account.
`newsletter@example-a.com` and `hello@example-b.com` went to Marketing as plain
commercial mail; `alerts@example-c.io` went to Tooling because it reports on the
owner's own automation rather than selling anything. All three are in the
"Guessed" section of `my-rules.md`, one line each to reverse.
Trashed: three "Updated Terms of Service" notices under the existing subject
rule. None of them contained a code or a verification link.
Confirmed bare and untouched: two one-time login links, a password reset, a
breach notification, and four messages from family addresses.

---

## 2026-01-16, pass 2 (gmail-full MCP)
All 14 filters confirmed present among 31 total; none created. 240 messages
labelled, nothing trashed, nothing deleted. The inbox is down to its
deliberately-bare set, so this pass was archive, working back from 2024-06 to
2023-11.
Breakdown: 94 Marketing, 68 Health, 40 Learning, 21 Work, 11 Finance,
4 Travel, 2 Tooling.
Judgement calls: the daily wellbeing newsletter kept splitting by subject rather
than by sender, per the owner's rule that content counts. Sleep and diet pieces
to Health, budgeting pieces to Finance, study-skills pieces to Learning, one
conference sales mail to Marketing. A retailer split the usual way: order and
shipping notices to Finance, promotional blasts to Marketing.
Confirmed bare and untouched: a login alert from a research site, and the
personal thread the owner asked to leave alone on 2026-01-15.

---

## 2026-01-17, pass 3 — CORRECTION
The owner reviewed pass 2 and ruled that `newsletter@example-a.com` should be
left bare, not Marketing. Removed the label from all 23 of its messages with
`batch_modify_emails` + `removeLabelIds`. Added the sender to the "Never label"
section of `my-rules.md`, in the owner's words.
No other changes this pass.
