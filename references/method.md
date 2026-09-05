# Method notes

What was learned running this over roughly 57 passes and several thousand
messages on a real 20-year-old Gmail account. Read `SKILL.md` first; this is the
detail behind it.

## Filters never touch old mail

A Gmail filter runs only on mail that arrives **after** the filter is created.
It never reaches backwards, and there is no "apply to existing conversations"
in the API.

So the job has two halves that do not overlap:

| | Handled by | Effort |
|---|---|---|
| Mail arriving from now on | Filters, automatically | Create once |
| The existing backlog | Batch labelling, by hand | One pass at a time |

Tell the owner this explicitly. Everyone assumes creating a filter cleans up the
archive, and it does not.

**The corollary that matters:** the first filters you create come from the
owner's known senders. But passes 3 through 50 keep discovering high-volume
senders nobody thought of, and those senders are still sending. Go back
periodically and add filters for the ones that appeared most often. Otherwise
the backlog rebuilds behind you while you clear the front.

## A filter can carry only one user label

`create_filter` rejects an action with two of your own labels:

```
Invalid filter criteria or action: Too many user labels in filter
```

Gmail's own system labels (`TRASH`, `IMPORTANT`, `CATEGORY_PROMOTIONS`) do not
count against it, so `addLabelIds: ["Label_73", "TRASH"]` is fine while
`["Label_73", "Label_20"]` is not.

When a sender genuinely earns two labels, make two filters: a broad one for the
sender, and a narrow one that adds `query: subject:(...)` for the subset that
earns the second label. That is the same sender-plus-content split the rules
file already describes, expressed as filters.

## Paging the archive by date, not by token

Page tokens expire and do not survive an interrupted session. Dates do.

```
has:nouserlabels -in:inbox -in:sent -in:draft -in:trash -in:spam -in:chats before:2020/03/01
```

Take 50 to 60 results. Note the date of the oldest one. Next call uses that date
as the new `before:`. Repeat. The window walks backwards through the archive and
you can stop and resume any time, on any day, without state.

The `-in:` exclusions matter:
- `-in:inbox` because the inbox is worked separately and first.
- `-in:sent` and `-in:draft` because labelling your own outbound mail is noise.
- `-in:trash` and `-in:spam` because that mail is already dispositioned.
- `-in:chats` because chat logs are not mail.

## The inbox empties, then stops emptying

After a few passes the inbox stops yielding anything. What is left is the
**deliberately bare set**: security alerts, login codes, data-export notices,
family mail, and whatever publications the owner has ruled off-limits.

That is the correct end state, not a failure. From then on every pass is
archive work. Say so in the log rather than reporting "nothing found", which
reads like the tool broke.

## Batch size and the concurrency error

`batch_modify_emails` takes up to 50 per call by default and will accept more.
Group the whole page by label first, then make one call per label.

Around three or four calls fired at once, Gmail returns:

```
Too many concurrent requests for user.
```

The call reports exactly which message IDs failed. Retry only those, in a
separate call. Do not retry the whole batch, or you will re-apply labels to
messages that already got them. That is harmless but it hides the real failure.

Practical shape: send the two or three biggest label groups as separate
sequential calls, then the small ones together.

## Reading a page fast

You do not need to open messages. Sender plus subject is enough for well over
90 percent of decisions, and the search results carry both. Open a message only
when the sender is new and the subject is ambiguous.

Speed matters because the decision quality comes from the rules file, not from
re-reading each mail. If you find yourself opening messages routinely, the rules
file is thin and that is what needs work.

## Multi-topic newsletters are the hard case

A single wellbeing or lifestyle newsletter will, across one month, send mail
that legitimately belongs under health, money, learning and career. Filing all
of it under one label is wrong, and it is the single largest source of
corrections.

Split by subject, and record the split in the log so it can be reviewed:

- Sleep, diet, exercise, stress → health
- Budgeting, investing, debt → money
- Study skills, languages, courses → learning
- Interviews, promotion, workplace → work
- Anything selling a conference, a course or a webinar → marketing

## What earns a second label

A thread can carry more than one. Genuine cases:

- A course provider's mail about a course in the owner's professional tool →
  learning **and** that tool's label.
- A receipt from a hobby service → the hobby label **and** money.
- A conference invitation in the owner's field → their field **and** marketing.

Do not add a second label to be thorough. Add it when both are independently
true and the owner would look under either one.

## Order notices versus promotional blasts

Big retailers send both from adjacent addresses. The rule that held up:

- **Order, shipping, delivery, refund and customs notices** → money.
- **Promotional blasts and sale announcements** → marketing.

Same brand, two buckets, decided by the subject. This applies to marketplaces,
ride apps, food delivery, parking services and app stores alike.

## Security mail stays bare, always

One-time codes, magic links, password resets, new-login notices, breach
notifications and data-export notices are never labelled and never trashed.

The reason is practical, not ceremonial: when someone needs a sign-in code they
search for it under time pressure, and a label does not help them find it any
faster while a trash rule actively loses it.

## The trash rule needs its negation

The terms-of-service subject rule is safe **only** with the negated query
attached. Without it:

> "Verify your email — we've updated our Terms of Use"

goes to Trash, and that is a sign-in link.

```
query:        subject:("terms of service" OR "terms and conditions" OR "terms of use"
                       OR "privacy policy" OR "user agreement")
negatedQuery: subject:(code OR verification OR verify OR "security alert" OR password)
```

Duplicate both halves for every language the account receives.

## Log the judgement calls, not the count

The useful part of an undo-log entry is not the count. It is the sentence that
says *this sender had no precedent, I put it here, for this reason*. That is the
line the owner reads and corrects.

Counts tell you the pass ran. Reasoning tells you whether it ran correctly.

## Ask the owner once, then write it down forever

When the owner rules on something — "leave that publication bare", "that person
is family", "that one is marketing after all" — write it into the rules file
immediately, in their words, with the date. Do not rely on remembering it next
pass. There will be fifty more passes and the reasoning will not survive them.
