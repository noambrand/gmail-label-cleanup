---
name: gmail-label-cleanup
description: Use when a Gmail account has thousands of unlabelled messages and needs sorting into existing labels, or when Gmail filters need creating in bulk. Installs a full Gmail MCP server (real filters, 50-message batches), learns the labelling rules from the account owner's own past labelling, then works the backlog in dated, reversible passes with an undo log.
---

# Gmail label cleanup

Sort a large Gmail backlog into the owner's own labels, and make future mail
label itself.

The built-in Gmail connectors in most assistants label one thread per call and
have no filter API. That is too slow for thousands of messages and cannot stop
the pile growing again. This skill uses a full Gmail MCP server instead, which
gives real server-side filters and 50-message batches.

## Before the first run

1. **Install the MCP server.** See `install/INSTALL.md`. It needs a Google Cloud
   OAuth desktop client and one browser sign-in. Roughly ten minutes, once.
2. **Create the rules file.** Copy `references/rules-TEMPLATE.md` to a private
   file (the template suggests `my-rules.md`, which `.gitignore` already
   excludes) and fill it in from the account's own history. **Never invent the
   rules.** See "Learning the rules" below.

## The one rule that makes this work

**Rules are learned from the owner's own past labelling, never invented.**

For each sender or subject, look at where that person already filed that sender
themselves, and copy it. Only when a sender appears nowhere in their history is
a judgement call allowed, and then it is recorded in a "guessed" section so it
can be corrected. A wrong label is cheap to fix; a wrong label applied silently
to 300 messages is not.

The second rule, learned the hard way: **content counts, not only the sender.**
A sender is one dimension. A newsletter about money from a wellbeing publisher
earns the money label as well. A thread can carry more than one label.

## Learning the rules

Ask the account, not the person. For each label, read what is already in it:

```
search_emails: label:"<label name>"
```

Read 30 to 50 results and write down the senders. That list is the rule. Repeat
for every label. Then `list_email_labels` to get the label IDs, which are what
`batch_modify_emails` actually takes.

Do this once, write it into the rules file, and keep appending to it every pass.
Each pass discovers senders the last one had not seen.

## Running a pass

A pass is one bounded, logged, reversible chunk of work. Aim for 200 to 300
messages. Do not try to do everything in one run.

**1. Confirm the filters exist.**

```
list_filters
```

If the rules file's filters are missing, create them first with `create_filter`,
one per label group, using `from:` criteria. Filters are the part that stops the
problem coming back.

**2. Find unlabelled mail.**

Inbox first:

```
search_emails: has:nouserlabels in:inbox
```

Once the inbox is down to the messages that are deliberately bare, the rest of
the work is archive. Page through it by date, oldest boundary moving each time:

```
search_emails: has:nouserlabels -in:inbox -in:sent -in:draft -in:trash -in:spam -in:chats before:YYYY/MM/DD
```

Take 50 to 60 per page. Set `before:` to the date of the oldest result you just
handled, and the next call continues where you stopped. This is more reliable
than paging tokens and it survives interruption.

**3. Group by label, then batch.**

Sort the page into one list of message IDs per label, then one
`batch_modify_emails` call per label with `addLabelIds`. Never one call per
message.

If a batch returns `Too many concurrent requests for user`, retry only the
failed IDs. The call reports exactly which ones failed.

**4. Log it.** Append a dated entry to the undo log. See "The undo log" below.

## Never touch

- **One-time login codes, magic links, password resets, and security alerts.**
  These stay unlabelled and are never trashed. If a person needs to find a
  sign-in code fast, a label does not help and a trash rule actively hurts.
- **Anything on the owner's own "never label" list.** People have publications
  and senders they want left bare, and they will tell you. Write each one into
  the rules file the moment they say it, in their words.
- **Family and personal mail**, unless the owner has already labelled that
  person themselves.

## Trashing

Trash only what the owner has explicitly authorised, and only by subject match.
The safe default set is terms-of-service and privacy-policy update notices:

```
subject:("terms of service" OR "terms and conditions" OR "terms of use"
         OR "privacy policy" OR "user agreement")
negatedQuery: subject:(code OR verification OR verify OR "security alert" OR password)
```

The negated query is not optional. Without it a "Verify your account - updated
terms" mail goes to Trash.

Gmail's Trash is recoverable for 30 days. Nothing in this skill ever deletes.

## The undo log

Every pass appends one dated entry. It is the record that makes the work
reversible and reviewable:

- The date and pass number.
- Whether filters existed, and any created.
- The count labelled, and the count per label.
- **Judgement calls**, named. Which senders had no precedent, what was decided,
  and why. This is the part that gets corrected later.
- What was confirmed bare and untouched.

See `examples/undo-log-EXAMPLE.md`. Write it even when the pass is boring.
Especially then.

## Filters do not touch old mail

This trips everyone up, so say it out loud to the owner:

**A Gmail filter only runs on mail that arrives after the filter is created.**
It never reaches backwards. So the two halves of this job are genuinely
separate: filters handle the future automatically, and the archive backlog has
to be worked by hand, pass by pass, exactly as described above.

Which means: after a few passes have discovered the real high-volume senders,
go back and add filters for them too. Otherwise those senders keep arriving
unlabelled and the backlog rebuilds itself behind you.

## Reversing a pass

Read the undo log entry for the pass, then `batch_modify_emails` with
`removeLabelIds` on the same message IDs. For anything trashed, `untrash` works
for 30 days. This is why the log records counts and reasoning rather than just
"done".
