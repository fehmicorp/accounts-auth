# =============================
# Stage 1 — Build the app
# =============================
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files first (leverage caching)
COPY package*.json ./

# Install all dependencies (including dev for build)
RUN npm ci

# Copy the rest of the project
COPY . .

# Build the Angular SSR project (adjust if your project uses a specific build command)
RUN npm run build || echo "No build:ssr script found"

# =============================
# Stage 2 — Production runtime
# =============================
FROM node:22-alpine

WORKDIR /app

# Copy only what's needed for runtime
COPY package*.json ./

# Copy built output from builder
COPY --from=builder /app/dist/auth ./dist

# Copy any server entry or assets if needed
COPY --from=builder /app/node_modules ./node_modules

# Set environment variables
ENV NODE_ENV=production
ENV PORT=4000

# Expose the SSR port
EXPOSE 4000

# Run the Angular Universal SSR server
CMD ["node", "dist/server/server.mjs"]
