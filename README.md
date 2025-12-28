# fix_privacy_permissions.sh 🔧

A small helper script to inject common privacy permissions (Microphone, Camera, Screen Capture, Dictation, Accessibility) into macOS's TCC database for all apps in `/Applications`.

---

## Install (one-liner)

> **Warning:** Running a script directly from the internet with `curl | bash` executes it immediately. Prefer the safer download-and-review flow shown below.

Direct (pipe-to-shell):

```bash
curl -fsSL https://raw.githubusercontent.com/<GITHUB_USER>/<REPO>/<BRANCH>/fix_privacy_permissions.sh | bash
```

Example (replace with your repo info):

```bash
curl -fsSL https://raw.githubusercontent.com/gerayeremin/core_video_mic_fix/main/fix_privacy_permissions.sh | bash
```

Safer (download, inspect, then run):

```bash
curl -fsSL -o /tmp/fix_privacy_permissions.sh https://raw.githubusercontent.com/<GITHUB_USER>/<REPO>/<BRANCH>/fix_privacy_permissions.sh
less /tmp/fix_privacy_permissions.sh    # review the script
bash /tmp/fix_privacy_permissions.sh
```

Optional: install to `/usr/local/bin` for reuse:

```bash
curl -fsSL -o /tmp/fix_privacy_permissions.sh https://raw.githubusercontent.com/<GITHUB_USER>/<REPO>/<BRANCH>/fix_privacy_permissions.sh
chmod +x /tmp/fix_privacy_permissions.sh
sudo mv /tmp/fix_privacy_permissions.sh /usr/local/bin/fix_privacy_permissions
fix_privacy_permissions
```

---

## Notes & Safety ⚠️

- The script **modifies the TCC database** located at `~/Library/Application Support/com.apple.TCC/TCC.db`. Always review the script before running it.
- You may need to grant **Terminal (or your shell app) Full Disk Access**: System Settings → Privacy & Security → Full Disk Access.
- The script takes a backup of the TCC database before changing anything.
- Prefer the download-and-review flow if you don't fully trust the source or want to inspect the code.
- If you want to verify integrity, you can host and verify a checksum or a GPG signature alongside the script.

---

## How to get the Raw GitHub URL

1. Open the file on GitHub in your repo: `https://github.com/<GITHUB_USER>/<REPO>/blob/<BRANCH>/fix_privacy_permissions.sh`
2. Click **Raw** and copy the URL in your browser — it will start with `https://raw.githubusercontent.com/…`.

---

If you'd like, I can add an install wrapper script that performs checksum verification, or a GitHub Action that publishes a signed release.
