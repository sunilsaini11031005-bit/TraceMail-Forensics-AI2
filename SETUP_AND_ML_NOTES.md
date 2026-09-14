# TraceMail Forensics AI — Complete Project (with real ML detection engine)

This is your full project with the ML upgrade already merged into `server/analyzer.js`.
`node_modules`, `dist`, `server/database.sqlite`, and `.env` were removed on purpose
(see below) — everything else is untouched from what you uploaded.

## ⚠️ Do this first: rotate your Fast2SMS API key

Your original `.env` had a live-looking Fast2SMS API key committed in plain text.
That file was **not** included in this zip. Please:
1. Go to your Fast2SMS dashboard and regenerate/revoke that key.
2. Copy `.env.example` to `.env` and fill in fresh values.
3. Never commit a real `.env` to a zip/repo you share — add `.env` to `.gitignore`.

## Setup

```bash
# 1. Install frontend deps
npm install

# 2. Install backend deps
cd server
npm install
cd ..

# 3. Set up environment
cp .env.example .env
# edit .env with your own keys (Fast2SMS / Twilio / Gmail — optional, only needed for OTP)

# 4. Run (check package.json / setup.sh for the exact scripts your version uses)
npm run dev          # frontend
cd server && node index.js   # backend, in a separate terminal
```

A fresh `server/database.sqlite` will be auto-created on first run, with a default
admin account (`admin` / `admin123` per the code in `server/index.js`) — **change
that password immediately after first login.**

## What's new: real ML detection engine

- `server/ml/textClassifier.js` + `server/ml/phishing_model.json` — a trained
  TF-IDF + Logistic Regression phishing/BEC text classifier (pure JS, no new npm deps).
- `server/analyzer.js` now calls this model instead of just counting urgency keywords.
  A new `"AI Content Classifier Flag"` risk factor and `analysisResult.mlClassifier`
  field show the model's real probability + top indicative terms.
- `ml-training/` — the scripts and dataset used to train it. Retrain anytime:
  ```bash
  cd ml-training
  # replace dataset.csv with a bigger/real corpus (text,label columns)
  python3 train_model.py
  cp phishing_model.json ../server/ml/phishing_model.json
  ```

## What's new: geolocation, authentication, attribution and attachments are now real

`server/analyzer.js` had a hardcoded table of ~10 demo IPs mapped to made-up cities
and made-up ISP names (a Vultr VPS IP labelled "HSBC Bank plc, London", a real Tor
exit node in Berlin labelled "Lagos, Nigeria", etc.), checked *before* the real
`ipwho.is` / `ipinfo.io` / `freeipapi.com` lookups that were already there — so those
specific IPs, and the "is this relay legitimate" logic tuned to match their fake ISP
names, never touched the real lookup at all. It's gone: every IP now goes through the
same live geolocation lookup, unconditionally.

Three other engines were already built, fully unit-tested (`server/auth/__tests__/`),
and completely real — independent SPF/DKIM/DMARC/ARC verification against live DNS
(`server/auth/`), evidence-based sender attribution (`server/attribution.js`), and
real MIME parsing with true byte sizes and SHA-256/MD5 hashes (`server/attachments.js`)
— but `analyzer.js` never called any of them. It still trusted whatever the message's
own `Authentication-Results` header claimed (trivially forgeable — an attacker can
just type `spf=pass` into a forged email), still built attachment "sizes" by hashing
the filename, and still returned an empty `threatActorProfile` stub. All three are now
wired into the live analysis path.

Also fixed while wiring this up:
- Domain-name extraction used an ASCII-only regex, so a homoglyph phishing domain like
  `pαypal-security.com` was silently truncated to `p` before ever reaching the
  typosquat/homoglyph detector — the exact evasion technique that detector exists to
  catch. It now keeps the full Unicode domain.
- The typosquat detector flagged a brand's own real domain (e.g. `hsbc.com`) as a
  lookalike of itself, because the "is this exactly the brand's domain" check compared
  against the bare word `hsbc` instead of `hsbc.com`.
- Blacklist count is now a real DNSBL check (Spamhaus ZEN, SpamCop, SORBS via DNS —
  no API key needed) instead of a hardcoded 0.
- Relay hop latency is now the real elapsed time between consecutive `Received`
  header timestamps where the headers carry parseable ones, instead of a formula with
  no connection to the message.
- The DNS records shown for a sending domain, and the final relay hop added for the
  recipient, used to fall back to plausible-looking invented records (or a hardcoded
  Google IP) when the real DNS lookup came back empty. They now report what was
  actually found, including "not found."

## Still honest limitations

- Training data for the ML classifier is template-generated (5,500 examples across
  105 templates, see `ML_NOTES.md`) — good for demoing/coursework, but retrain on a
  real corpus (Nazario Phishing Corpus, CEAS 2008, Enron-Spam, or a Kaggle
  phishing-email dataset) before treating this as production-accurate.
- A specific threat-actor name/group, dark web mentions, and known-target history
  genuinely need a connected threat-intelligence feed and a dark web monitoring
  subscription this project doesn't have; `threatActorProfile.notAvailable` says so
  explicitly per field rather than guessing.
- Auth in `server/index.js` (the app's own login system, not the email-authentication
  engine in `server/auth/`) uses unsalted SHA-256 passwords and a non-cryptographic
  (forgeable) session token, and Google OAuth tokens aren't signature-verified — worth
  fixing before any real/public deployment.
- This session's sandbox couldn't make outbound HTTPS calls to the geolocation APIs
  or resolve DNS TXT records to test the SPF/DMARC/WHOIS paths live end-to-end (the
  code was verified against the real `ipwho.is` API through a different channel, and
  against the project's own unit test suite, which passed 83/83) — run a real analysis
  once after pulling this to confirm on your own machine's normal internet connection.
