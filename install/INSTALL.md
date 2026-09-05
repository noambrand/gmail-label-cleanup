# Installing the Gmail MCP server

This gives your assistant real Gmail filters and 50-message batches. Without it
you get one-thread-at-a-time labelling and no filter API, which is not enough
for a backlog of thousands.

The server is [ArtyMcLabin/Gmail-MCP-Server](https://github.com/ArtyMcLabin/Gmail-MCP-Server),
published on npm as `@artymclabin/gmail-mcp`.

## What you need first

- **Node.js 18 or newer.** Check with `node -v`.
- **A Google account** whose mail you want sorted.
- **A Google Cloud project** with an OAuth 2.0 **Desktop app** client. If you
  already made one for another script, reuse it. Creating one is free and takes
  about five minutes:
  1. Go to https://console.cloud.google.com/apis/credentials
  2. Create Credentials, then OAuth client ID, then application type **Desktop app**.
  3. Download the JSON. That file is what the installer asks for.
  4. On the OAuth consent screen, add your own Google address under **Test users**.
     Without this the sign-in is refused.

## Scopes it asks for

`gmail.modify` and `gmail.settings.basic`. In plain terms: read mail, add and
remove labels, move to Trash, and create filters. It cannot permanently delete,
and it cannot change your password or recovery settings.

Your mail never leaves your machine and Google. The server runs locally.

## Install

**Windows:** double-click `install-gmail-mcp.cmd`.

**macOS or Linux:** run `bash install-gmail-mcp.sh`.

Either way it does four things:

1. Copies your OAuth client JSON to `~/.gmail-mcp/gcp-oauth.keys.json`, where
   the server looks for it.
2. Opens the Google Cloud page so you can switch the **Gmail API** on for that
   project. Click the blue ENABLE button. If it already says MANAGE, it is on.
3. Runs the sign-in. A browser tab opens. Pick your account, click through the
   unverified-app warning (it is your own app), and allow.
4. Registers the server with Claude Code as `gmail-full`.

The token lands in `~/.gmail-mcp/credentials.json`.

## After installing

**Restart your assistant.** The new tools are not visible in the session that
installed them. They load on the next start.

Check it worked:

```
claude mcp get gmail-full
```

It should say **Connected**.

## If the token expires

Re-run the same installer. Steps 1, 2 and 4 are harmless to repeat.

## If your assistant is not Claude Code

Step 4 is the only Claude Code-specific part. For any other MCP client, add the
server to its config by hand:

```json
{
  "mcpServers": {
    "gmail-full": {
      "command": "npx",
      "args": ["-y", "@artymclabin/gmail-mcp"]
    }
  }
}
```

Steps 1 to 3 are the same everywhere.

## Tools you get

`search_emails`, `read_email`, `batch_modify_emails`, `modify_email`,
`modify_thread`, `get_thread`, `list_email_labels`, `create_label`,
`get_or_create_label`, `update_label`, `delete_label`, `create_filter`,
`list_filters`, `get_filter`, `delete_filter`, `create_filter_from_template`,
`send_email`, `draft_email`, `update_draft`, `send_draft`, `delete_draft`,
`reply_all`, `download_email`, `download_attachment`, `report_phishing`,
`batch_report_phishing`, `get_inbox_with_threads`, `list_inbox_threads`.

The four that matter for this skill are `list_filters`, `create_filter`,
`search_emails` and `batch_modify_emails`.
