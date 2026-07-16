# Discord Log Forwarder Bot

Watches a channel in **Server 1**, checks each message against a required
format, and either:

- **Valid** → forwards the message to a channel in **Server 2**
- **Invalid** → replies to the original message with
  `Error - Format not followed. Log again or dm @russiancatmaid if you believe this is a mistake`

## Required format

A valid message must be exactly `REQUIRED_FIELDS` (default `5`) non-blank
lines, each shaped like `Label: value`, where `value` is actually filled in
(not empty and not left as `*`). Example of a valid message with 5 fields:

```
Field 1: something
Field 2: something
Field 3: something
Field 4: something
Field 5: something
```

Any label text works — only the line count and "value present" check are
enforced. Adjust `REQUIRED_FIELDS` in `.env` if the number of fields changes.

## 1. Create the bot (Discord Developer Portal)

1. Go to https://discord.com/developers/applications → **New Application**.
2. **Bot** tab → **Reset Token** → copy it (this is `DISCORD_BOT_TOKEN`).
3. On the same **Bot** tab, enable **Message Content Intent** under
   *Privileged Gateway Intents* — the bot cannot read message text without it.
4. **OAuth2 → URL Generator**: scope `bot`, permissions `View Channel`,
   `Send Messages`, `Read Message History`. Use the generated URL to invite
   the bot to **both** Server 1 and Server 2.
5. Enable Developer Mode in Discord (User Settings → Advanced), then
   right-click the source channel in Server 1 and the destination channel
   in Server 2 to **Copy Channel ID** for each.

## 2. Push this repo to GitHub/GitLab (from your local machine)

```bash
git remote add origin <your-repo-url>
git branch -M main
git push -u origin main
```

(`.env` is git-ignored, so your token never gets committed — only `.env.example` is tracked.)

## 3. Deploy to the Ubuntu droplet

SSH into the droplet, install git if needed, and clone the repo:

```bash
sudo apt update && sudo apt install -y git
git clone <your-repo-url> ~/discord-log-forwarder
cd ~/discord-log-forwarder
chmod +x setup.sh update.sh
./setup.sh
```

`setup.sh` installs Python/venv, installs dependencies, creates `.env` from
`.env.example` (if it doesn't exist yet), and registers a systemd service
that runs as your current user from wherever you cloned the repo.

Then fill in your real config and start the bot:

```bash
nano .env   # fill in DISCORD_BOT_TOKEN, SOURCE_CHANNEL_ID, DEST_CHANNEL_ID
sudo systemctl start discord-log-forwarder
```

Check status / logs:

```bash
sudo systemctl status discord-log-forwarder
sudo journalctl -u discord-log-forwarder -f
```

The service restarts automatically on crash or droplet reboot (`systemctl enable` was run by `setup.sh`).

## Updating the bot later

Push your changes to the git remote, then on the droplet:

```bash
./update.sh
```

This pulls the latest code, reinstalls dependencies, and restarts the service.

## Local testing (optional, before deploying)

```bash
python3 -m venv venv
./venv/bin/pip install -r requirements.txt
cp .env.example .env   # fill in real values
./venv/bin/python bot.py
```
