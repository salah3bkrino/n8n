# Build Stage
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies for building n8n
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    sqlite-dev \
    git

# Copy the entire mono-repo
COPY . .

# Install pnpm and build n8n
RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile && \
    pnpm build

# Final Stage
FROM node:18-alpine

WORKDIR /home/node

# Set environment
ENV NODE_ENV=production

# Copy built files from core/cli
# In the mono-repo, the main entry point is in packages/cli
COPY --from=builder /app /app

# Link n8n
RUN npm install -g pnpm && \
    pnpm link /app/packages/cli

EXPOSE 5678/tcp

ENTRYPOINT ["n8n"]
