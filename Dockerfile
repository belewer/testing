FROM alpine AS build

WORKDIR /app

COPY ./index.js ./
COPY ./package*.json ./

RUN apk add nodejs npm curl --no-cache && \
    npm install --production && \
    curl -sf https://gobinaries.com/tj/node-prune | sh && \
    node-prune

FROM alpine

WORKDIR /app

RUN apk add nodejs npm --no-cache && \
    adduser -D node

USER node

COPY --from=build /app/index.js ./
COPY --from=build /app/package.json ./
COPY --from=build /app/node_modules ./node_modules/

EXPOSE 3000

CMD ["npm","start"]
