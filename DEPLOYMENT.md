# 🚀 TraceMail Forensics AI — Live Production Deployment Guide

TraceMail Forensics AI is built as a **unified full-stack application**. In production, the backend Node.js server serves both the **compiled React Dashboard UI** and all **Backend APIs** on a single port.

---

## 🌟 Option 1: Deploy on Render.com (Recommended - Free & Turnkey)

1. Push your repository to **GitHub**.
2. Go to [https://render.com](https://render.com) and sign in.
3. Click **New +** ➔ **Web Service**.
4. Connect your GitHub repository.
5. Set the following configuration:
   * **Name**: 	racemail-ai
   * **Runtime**: Node
   * **Build Command**: 
pm install && cd server && npm install && cd .. && npm run build
   * **Start Command**: 
pm start
   * **Instance Type**: Free
6. Under **Environment Variables**, add:
   * NODE_ENV = production
   * PORT = 10000 (Render will map this automatically)
   * APP_ACCESS_KEY = (generate any 32-character random string or keep default)
   * *(Optional)* EMAIL_USER & EMAIL_PASS (Gmail App Password for real OTP emails)
   * *(Optional)* TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER (For real SMS OTP)
7. Click **Create Web Service**. Within 2-3 minutes, your software will be live at https://your-app-name.onrender.com!

---

## 🚂 Option 2: Deploy on Railway.app (Fastest 1-Click with Docker)

1. Sign in to [https://railway.app](https://railway.app).
2. Click **New Project** ➔ **Deploy from GitHub repo**.
3. Select this repository.
4. Railway will automatically detect the Dockerfile and build the container.
5. In project **Settings** ➔ **Networking** ➔ Click **Generate Domain**.
6. That's it! Your app will be live on https://your-app-name.up.railway.app.

---

## 🐳 Option 3: Deploy with Docker on Any VPS (Ubuntu / Debian / AWS / DigitalOcean)

### Step 1: Install Docker on your server
`ash
sudo apt update
sudo apt install -y docker.io docker-compose
`

### Step 2: Clone repository & build container
`ash
git clone <your-repo-url>
cd tracemail-upgraded/tracemail-upgraded
sudo docker build -t tracemail-ai .
`

### Step 3: Run the container
`ash
sudo docker run -d \
  --name tracemail \
  --restart always \
  -p 80:3001 \
  -v C:\Users\sunil\Documents\tracemail-upgraded\tracemail-upgraded\tracemail-upgraded/server/data:/app/server/data \
  -e DB_PATH=/app/server/data/database.sqlite \
  tracemail-ai
`

Your software will now be accessible directly on http://your-server-ip/!

---

## 🛠️ Testing Production Mode Locally Before Deploying

You can verify production mode right on your computer:

`powershell
# 1. Build the production React frontend
npm run build

# 2. Run the production unified server
$env:NODE_ENV="production"; npm start
`

Open http://localhost:3001 in your browser. Both the React Dashboard and APIs will be running seamlessly on port 3001!
