FROM node:20-bookworm-slim AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json ./
COPY src ./src

RUN npm run build && npm prune --omit=dev

FROM node:20-bookworm-slim AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV CURSOR_INSTALL_URL=https://cursor.com/install

RUN apt-get update \
  && apt-get install -y --no-install-recommends bash ca-certificates curl git \
  && rm -rf /var/lib/apt/lists/*

# Install Cursor Agent CLI and expose compatible command names.
RUN set -eux; \
  curl -fsSL "${CURSOR_INSTALL_URL}" | bash; \
  ln -sf /root/.local/bin/cursor-agent /usr/local/bin/cursor-agent; \
  ln -sf /root/.local/bin/agent /usr/local/bin/agent; \
  ln -sf /usr/local/bin/cursor-agent /usr/local/bin/cursor

COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/package-lock.json ./package-lock.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY docker/start.sh /usr/local/bin/start-gateway

RUN chmod +x /usr/local/bin/start-gateway \
  && mkdir -p /tmp/cursor-empty-workspace

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/start-gateway"]
