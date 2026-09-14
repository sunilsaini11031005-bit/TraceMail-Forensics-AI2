# TraceMail — ML detection engine

The text classifier that decides how likely an email is to be phishing, BEC,
credential harvesting, invoice fraud, a malware lure or extortion.

Training lives in `ml-training/`. Inference is pure JavaScript in
`server/ml/textClassifier.js` — no Python, no npm dependency, no model server.
`server/analyzer.js` calls it and turns the score into the
`"AI Content Classifier Flag"` risk factor and the `analysisResult.mlClassifier`
block.

## Retraining

```bash
cd ml-training
python3 generate_dataset.py     # rebuild the synthetic corpus (optional)
python3 train_model.py          # train + evaluate, writes phishing_model.json
python3 verify_parity.py        # JS must score identically -- see below
cp phishing_model.json ../server/ml/phishing_model.json
```

Needs `scikit-learn`, `pandas`, `numpy`, `scipy` (`pip install scikit-learn
scipy numpy`) and Node for the parity check. `train_model.py --quick` skips the
C grid search when you just want a fast rebuild.

## The model

| | |
|---|---|
| Features | word TF-IDF, 1–2 grams, sublinear tf, ≤15k features |
| | + `char_wb` TF-IDF, 3–5 grams, sublinear tf, ≤15k features |
| Classifier | Logistic regression, `class_weight="balanced"`, C by grouped CV |
| Threshold | calibrated on out-of-fold scores, shipped inside the model file |
| Runtime cost | one JSON load (~0.8 MB) at first call, then pure arithmetic |

The character n-grams are there for a specific reason: they are what catch the
obfuscation real phishing uses — `paypa1`, `micros0ft`, `netfIix`, `docus1gn`.
A word-only model sees those as three unrelated words it has never met and
scores them as neutral.

## How it is evaluated, and why the old number was wrong

Every figure below is **out-of-fold under a template-disjoint 5-fold split**:
each message is scored only by a model trained without it, *and* without any
other message generated from the same template.

That last clause is the whole point. The previous version reported held-out
accuracy from a random row split, which on templated data measures nothing —
the test rows are rephrasings of training rows, so the model scores ~100% by
recognising sentence shapes it has already memorised. Running that same split
on the current, larger dataset still gives **100.0%**. The honest number, on
templates the model has genuinely never seen, is:

| Metric | Value |
|---|---|
| Accuracy | **0.873** |
| ROC AUC | **0.934** |
| False positives (clean mail flagged) | 11.6% |
| False negatives (phish missed) | 13.9% |
| Decision threshold | 0.54 |
| Training examples | 5,500 across 105 templates |

Lower than the old headline figure, and much closer to what the thing will
actually do on an email it has never seen.

## The dataset

`generate_dataset.py` produces 5,500 messages from 105 templates, each wrapped
in randomised subjects, greetings, sign-offs, names, brands, amounts, deadlines
and URLs.

Two design choices carry most of the weight:

**Hard negatives.** About 55% of the legitimate half deliberately contains the
exact surface features a keyword detector treats as phishing — real password
reset mail, genuine security alerts, invoices with due dates, receipts with
amounts, wire instructions, urgent internal escalations, security-awareness mail
that *talks about* phishing. Without these the model learns "urgent + link =
bad" and flags every legitimate billing notice in production.

**Hard positives.** Some malicious mail carries no link, no amount and no
urgency at all — the BEC reconnaissance opener ("Are you at your desk?") reads
exactly like a benign note, because that is the point of it. The model misses
most of these, and it should: there is nothing in the text to go on. Catching
them needs sender and header signals, not language.

Greeting and sign-off style is chosen by the *shape* of the message (one-to-one
note vs. bulk notification), never by its label, so "Dear customer" and "The
PayPal Team" appear on both real notifications and phishing and carry no free
signal.

## Using a real corpus

Drop real labelled mail into `ml-training/data/` and it is merged in
automatically on the next `train_model.py` — `.eml`, `.mbox` or `.csv`, labelled
by folder name or column. `ml-training/data/README.md` has the layouts and links
to Nazario, SpamAssassin, Enron-Spam and CEAS. Once there is enough of it,
`python3 train_model.py --no-synthetic` drops the synthetic set entirely.

The folder is gitignored: those corpora are real people's mail and some licences
forbid redistribution.

One trap worth knowing about. Nazario phishing is from 2004–2015 and
SpamAssassin ham from 2002, so a model trained on both can hit 99% by learning
which decade an email is from rather than what makes it malicious. `corpus.py`
keeps only subject and body and strips headers, which removes the worst of it,
but mixing sources and eras on both sides is still worth the effort.

## verify_parity.py

`textClassifier.js` reimplements `TfidfVectorizer` by hand — two analyzers,
sublinear tf, smooth idf, per-block L2 normalisation, sklearn's exact
`char_wb` padding rule. It can drift from the Python that trained the weights
without anything visibly breaking: the server just keeps returning
plausible-looking probabilities that are quietly wrong.

`verify_parity.py` rebuilds the vectorizers in Python from the exported model
(loading the shipped vocabularies and IDF vectors, not refitting), scores 23
awkward messages both ways — empty strings, emoji, Devanagari, accented text,
repeated tokens, 200-character words, HTML fragments, obfuscated brands — and
fails if any pair differs by more than 1e-9. Current worst difference: 3.3e-16,
which is floating-point noise.

Run it after every retrain and after any edit to `textClassifier.js`.

## Honest limitations

- **The text is still synthetic.** The numbers above measure generalisation to
  unseen phrasing, not to real mail. Add a real corpus before quoting any of
  this as production accuracy.
- **Text only.** The classifier reads subject and body. Sender reputation, SPF
  and DKIM results, header anomalies, reply-to mismatch and URL reputation are
  all stronger signals for several attack types and none of them reach this
  model.
- **Short pretexting mail is not detectable from text.** See "hard positives"
  above.
- **Unchanged from before, still open:** domain WHOIS fields, blacklist counts
  and the "Threat Actor Profile" in `analyzer.js` are randomly generated rather
  than real lookups. Auth in `server/index.js` uses unsalted SHA-256 passwords
  and a forgeable session token, Google OAuth tokens are not signature-verified,
  and there is a default `admin` / `admin123` account. None of that is touched
  by this work.
