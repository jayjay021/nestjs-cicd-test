FROM node:20-alpine AS build

ARG NODE_AUTH_TOKEN
ENV NODE_AUTH_TOKEN ${NODE_AUTH_TOKEN}

WORKDIR /app
RUN npm install -g pnpm
RUN npm install -g @nestjs/cli
RUN npm install -g @yao-pkg/pkg

# pnpm fetch does require only lockfile
COPY --chown=node:node pnpm-lock.yaml ./
COPY --chown=node:node .npmrc ./

RUN pnpm fetch


ADD --chown=node:node . ./
RUN pnpm install -r --offline
RUN pnpm run build

RUN pkg -C Gzip -o app .


FROM alpine AS production
RUN addgroup -S node && adduser -S node -G node
USER node

WORKDIR /app

COPY --chown=node:node --from=build /app/app .


EXPOSE 3000
CMD [ "./app" ]