# ==========================================
# TraceMail Forensics AI - Production Dockerfile
# ==========================================

FROM node:20-alpine AS base
WORKDIR /app

# Install dependencies for both frontend and backend
COPY package*.json ./
COPY server/package*.json ./server/

RUN npm ci --legacy-peer-deps && cd server && npm ci --legacy-peer-deps

# Copy entire source code
COPY . .

# Build Vite frontend assets into dist/
RUN npm run build

# Set production environment
ENV NODE_ENV=production
ENV PORT=3001
ENV HOST=0.0.0.0

EXPOSE 3001

# Start the unified backend server which serves both frontend UI and APIs
CMD ["npm", "start"]
