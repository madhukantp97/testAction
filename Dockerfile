# Stage 1: Base image
FROM node:20-alpine AS base

FROM base AS deps

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

FROM base AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules

COPY . .
RUN npm run build

FROM base AS runner

WORKDIR /app

ENV NODE_ENV production
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Ensure the .next directory is created and owned correctly
RUN mkdir -p .next && chown nextjs:nodejs .next


RUN mkdir .nextjs


USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
