# gmail-label-cleanup

An agent skill for sorting a large Gmail backlog into the labels you already
use, and making future mail label itself.

Built while clearing a real 20-year-old Gmail account with several thousand
unlabelled messages. It works.

## The problem

The Gmail connectors built into most AI assistants label one thread per call and
have no filter API. At that speed a few thousand messages is not worth starting,
and even if you finish, the pile starts growing again the next morning.

## What this does

- Installs a **full Gmail MCP server** that has real server-side filters and
  50-message batches.
- Teaches the assistant your labelling rules **by reading how you already
  labelled your own mail**, not by inventing categories.
- Works the backlog in **dated, bounded, reversible passes** with an undo log.
- Creates **filters** so new mail sorts itself from then on.

## The two halves of the job

This is the thing everyone gets wrong, so it is the first thing here:

**A Gmail filter only runs on mail that arrives after you create it.** It never
reaches backwards into your archive.

| | Handled by | Effort |
|---|---|---|
| Mail arriving from now on | Filters | Create once |
| Your existing backlog | Batch labelling | One pass at a time |

## Install

1. Read [`install/INSTALL.md`](install/INSTALL.md).
2. Windows: double-click `install/install-gmail-mcp.cmd`.
   macOS or Linux: `bash install/install-gmail-mcp.sh`.
3. Restart your assistant.

You need Node 18+, a Google account, and a Google Cloud OAuth "Desktop app"
client. About ten minutes, once.

The MCP server is
[ArtyMcLabin/Gmail-MCP-Server](https://github.com/ArtyMcLabin/Gmail-MCP-Server)
(`@artymclabin/gmail-mcp`). It runs locally. Your mail goes nowhere except
between your machine and Google.

## Set up your rules

Copy [`references/rules-TEMPLATE.md`](references/rules-TEMPLATE.md) to
`my-rules.md` and fill it in. The template walks you through it.

**`my-rules.md` is gitignored on purpose.** A filled-in copy is a map of who you
bank with, who your doctor is, and who your family are. Keep it local.

The one principle the whole thing rests on: **rules are learned from your own
past labelling, never invented.** For each sender, look at where you already
filed that sender yourself, and copy it.

## Run it

Ask your assistant:

> Gmail backlog pass. Read my-rules.md. Confirm the filters exist, create any
> that are missing, then clear unlabelled mail 50 at a time, up to 300 messages
> this run. Never trash one-time codes or security alerts. Append a dated
> summary to the undo log.

Then read the log entry it writes, and correct anything it guessed wrong. The
corrections go into `my-rules.md` and the next pass is better.

## What it will not do

- It never permanently deletes. Trash only, and only from subject rules you
  authorised. Gmail's Trash is recoverable for 30 days.
- It never labels or trashes one-time codes, magic links, password resets or
  security alerts.
- It never invents a category you do not already use.

## Files

```
SKILL.md                        the skill itself
README.md                       this file
install/INSTALL.md              MCP server setup, prerequisites, scopes
install/install-gmail-mcp.cmd   Windows one-click installer
install/install-gmail-mcp.sh    macOS and Linux installer
references/rules-TEMPLATE.md    copy to my-rules.md and fill in
references/method.md            what was learned over ~57 real passes
examples/undo-log-EXAMPLE.md    the log format, including a correction entry
```

## Using it with Claude Code

Drop the folder into `~/.claude/skills/` (or your project's `.claude/skills/`)
and the skill is available as `gmail-label-cleanup`.

Any other MCP-capable assistant works too. Only step 4 of the installer is
Claude Code-specific, and `INSTALL.md` gives the config snippet for everything
else.

## Licence

MIT. See [`LICENSE`](LICENSE).
