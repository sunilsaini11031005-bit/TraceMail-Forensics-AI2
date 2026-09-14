import fs from 'fs';
import { jsPDF } from 'jspdf';

const doc = new jsPDF();

const text = `
TraceMail Forensics AI - Software Documentation

1. What does the software do?
TraceMail Forensics AI is an advanced email forensics and cyber security analysis tool. It deeply analyzes suspicious emails (phishing, spam) to detect hackers. It scans email headers, body, and attachments to find the real IP address, original location, and tricks used by attackers.

2. What are the features?
- Email Header & Routing Analysis
- ML based Text Classifier (Phishing/BEC Detection)
- Email Authentication Verification (SPF, DKIM, DMARC, ARC)
- IP Geolocation and Hop Tracking
- VPN / Proxy / Tor Network Detection
- Domain Analysis & Typosquatting/Homoglyph Detection
- Attachment Scanning and Hashing (Forensics)
- Threat Actor Attribution
- MITRE ATT&CK Mapping & Playbook Recommendations
- URL Extraction and Shortener Detection
- Honeypot Tracker
- Asynchronous Analysis Queue

3. How does each feature work?

1. Email Header & Routing Analysis: Reads raw email data, extracts Received, From, To, Subject headers, and traces the hops the email passed through. Identifies latency between hops or missing headers.

2. ML based Text Classifier: Uses a TF-IDF + Logistic Regression model to classify email text. It finds words commonly used by hackers ("Urgent", "Wire Transfer") and calculates a probability score for social engineering.

3. Authentication Verification: Contacts live DNS to check if the sender server has permission (SPF), validates digital signatures (DKIM) and policies (DMARC).

4. IP Geolocation & Hop Tracking: Extracts IP addresses and uses live APIs to map them to countries, ISPs, and checks for private IPs.

5. VPN/Proxy Intel: Detects if the sending IP belongs to a known VPN provider, open proxy, or Tor exit node.

6. Domain Analysis & Typosquatting: Checks domains at a Unicode level to catch homoglyphs (e.g. pαypal.com) and compares them with real brands. Checks DNSBL for blacklists.

7. Attachment Scanning: Checks the real size and MIME type of attachments. Generates MD5/SHA-256 hashes to check against malware databases.

8. Threat Actor Attribution: Identifies timezone, email client, and OS based on X-Mailer and Message-ID patterns.

9. MITRE ATT&CK Mapping: Maps threats to MITRE tactics (e.g. T1566) and recommends SOC playbooks for response.

10. URL Extraction: Extracts URLs and flags URL shorteners (bit.ly, etc.) commonly used to hide malicious links.

11. Honeypot Tracker: Leaves traps to catch automated bots and records their IPs.

12. Analysis Queue: Uses Redis/In-memory queue to process thousands of emails asynchronously without crashing.
`;

const lines = doc.splitTextToSize(text, 180);
doc.text(lines, 10, 10);
doc.save('../../TraceMail_Documentation.pdf');
console.log('PDF generated at ../../TraceMail_Documentation.pdf');
