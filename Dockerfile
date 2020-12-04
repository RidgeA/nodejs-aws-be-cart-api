# build: docker build -t ridgea-rss-app-cart-api:latest .

FROM node:14 AS base
WORKDIR /app
RUN npm i -g node-prune

FROM base AS dependencies
COPY package*.json ./
RUN npm ci && npm cache clean --force

FROM dependencies AS build
WORKDIR /app
COPY . .
RUN npm run build

FROM build as prodDependencies
WORKDIR /app
COPY --from=dependencies /app/package*.json ./
COPY --from=dependencies /app/node_modules ./node_modules/
RUN npm prune --production && node-prune

FROM node:14-alpine
WORKDIR /app
COPY --from=prodDependencies /app/node_modules /app/node_modules
COPY --from=build /app/dist /app
EXPOSE 4000
CMD ["node", "main.js"]
