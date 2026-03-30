FROM node:20-slim

RUN corepack enable && corepack prepare pnpm@9.15.4 --activate

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/worker/package.json apps/worker/
COPY apps/web/package.json apps/web/
COPY apps/liff/package.json apps/liff/
COPY packages/db/package.json packages/db/
COPY packages/shared/package.json packages/shared/
COPY packages/line-sdk/package.json packages/line-sdk/
COPY packages/sdk/package.json packages/sdk/
COPY packages/mcp-server/package.json packages/mcp-server/
COPY packages/plugin-template/package.json packages/plugin-template/

RUN pnpm install --frozen-lockfile
RUN npm install -g serve

COPY . .
