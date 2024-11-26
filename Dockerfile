FROM node:20-alpine

RUN apk add --no-cache \
      ca-certificates \
      chromium \
      freetype \
      harfbuzz \
      nss \
      ttf-freefont

ENV SHELL=/usr/bin/bash
ENV PNPM_HOME=/usr/local/bin

RUN corepack enable && corepack prepare pnpm@latest --activate

RUN pnpm install -g unlighthouse puppeteer

EXPOSE 5678

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN chown root:root /usr/lib/chromium/chrome-sandbox && \
    chmod 4755 /usr/lib/chromium/chrome-sandbox

# Add user so we don't need --no-sandbox.
RUN addgroup -S unlighthouse && adduser -S -G unlighthouse unlighthouse \
    && mkdir -p /home/unlighthouse/Downloads /app \
    && chown -R unlighthouse:unlighthouse /home/unlighthouse \
    && chown -R unlighthouse:unlighthouse /app

# Run everything after as non-privileged user.
USER unlighthouse
WORKDIR /home/unlighthouse
