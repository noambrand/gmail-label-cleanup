# Gmail labelling rules — TEMPLATE

Copy this to `my-rules.md` and fill it in. `.gitignore` already excludes
`my-rules.md`, because a filled-in copy is a map of who you bank with, who your
doctor is, and who your family are. **Do not commit a filled-in copy to a public
repository.**

> **These rules are LEARNED FROM YOUR OWN LABELLING, not invented.** Every
> sender below should be read out of mail you had already filed yourself. When a
> new sender turns up, the method is the same: look at where you filed that
> sender before, and copy it. Only when a sender appears nowhere in your history
> is a judgement call allowed, and then it goes in the "Guessed" section at the
> bottom so it can be corrected.

---

## Label ids

`batch_modify_emails` takes label **IDs**, not names. Get them once with
`list_email_labels` and paste them here. Gmail's own labels have readable IDs;
yours look like `Label_12` or `Label_1234567890123456789`.

| Label | id |
|---|---|
| _(your label)_ | _(Label_xx)_ |
| _(your label)_ | _(Label_xx)_ |

---

## Learned from my own labelling — apply without thinking twice

One block per label. List the senders you have already filed there. Domains are
fine where the whole domain belongs to one bucket.

**_(Label name)_** (`Label_xx`) — seen on my own mail from this label:
`sender@example.com` · `another@example.com` · `example-domain.com`

**_(Label name)_** (`Label_xx`) —
`sender@example.com` · `example-domain.com`

_Repeat for every label._

---

## Careful: senders that are only a relay

A domain rule is a default, not a verdict. Two patterns that bite:

- **Bulk-mail relays.** A single relay domain carries mail from many unrelated
  businesses. Never rule on the relay domain alone. Look at the local part
  before the `@`, or at the subject.
- **A person forwarding something.** Mail from a colleague's work address is not
  automatically work mail. Personal notes forwarded from an institutional
  address get left bare, not filed under that institution.

List yours here as you find them, with the reason:

- `relay-domain.example` — carries several unrelated senders. Check the local
  part or the subject, never the domain alone.

---

## Content counts, not only the sender

**The sender is one dimension, not the rule.** A label is earned by what the
mail is *about* as much as by who sent it, and a thread may carry more than one
label.

So subject rules are NOT a fallback for when a sender rule misses. They run **in
addition**, and a mail can end up with both. A newsletter from a marketing
sender whose subject is about a course earns both the marketing label and the
learning label.

This matters most for daily-newsletter senders that cover many topics. A single
wellbeing newsletter can produce mail that belongs under health, money, learning
and career in the same week. Split it by subject; do not force one label on the
sender.

**_(Label)_ by content** (`Label_xx`) — subject contains any of:
`keyword` · `keyword` · `keyword`

Known false positives to skip by hand: _(a word that matches the keyword but
means something else, e.g. a person's name that contains a product name)_.

---

## Subject rules (additive, alongside the sender rules)

- **_(Label)_** — `keyword` · `"exact phrase"`
- **_(Label)_** — `keyword`

---

## Discovered senders, by pass

Append here every pass. This is the section that grows. Each entry is one line
to reverse if it turns out wrong.

**Pass 1 (YYYY-MM-DD)** — **_(Label)_**: `sender` · `sender`.
**_(Label)_**: `sender`. **Bare**: `sender` _(and why)_.

---

## Never label

The owner's own rulings, in their words. Publications and people whose mail they
want left bare. Add each one the moment they say it.

- `sender@example.com` — _(their reason, quoted)_

---

## Deliberately bare (transactional, and never to be trashed)

These stay unlabelled on purpose and must never be trashed:

- One-time login codes and magic links
- Password resets
- Security alerts and new-login notices
- Account data exports and takeout notices
- Family and personal mail, unless already filed by the owner

---

## Trash rules

Move to Trash, do not label: subject contains
`"terms of service"` · `"terms and conditions"` · `"terms of use"` ·
`"privacy policy"` · `"user agreement"`

**Always pair it with a negated query**, or a "Verify your account - updated
terms" mail goes to Trash:

```
negatedQuery: subject:(code OR verification OR verify OR "security alert" OR password)
```

**Never trash automatically:** one-time login codes and security alerts.

Add the same pair for any other language you receive mail in.

---

## The signature trap

If you run a business, your own signature contains your product name, so those
words appear in almost every message you have ever sent. Do **not** label a
thread with your product label just because the words appear in it.

Label it with the product only when the mail is genuinely about the product: a
customer, a licence, the domain, the channel, the form, or the tooling.

Write your own version of this trap here, naming the words that appear in your
signature.

---

## Guessed, not learned — correct these if wrong

Senders that had no precedent anywhere in the account. Applied under the rule
"better a label than no label at all". Each is one line to reverse.

`sender@example.com` → _(Label)_
`sender@example.com` → _(Label)_
