### STAGE 1: Build ###
#FROM registry.turacocloud.com/turaco-package/node:16.14.0 as build-stage
#FROM registry.turacocloud.com/turaco-package/node:18.15.0-alpine3.17 as build-stage
FROM registry.turacocloud.com/turaco-package/node:20-alpine as build-stage
ARG PROFILE
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH

COPY package*.json ./

RUN npm install
COPY . .
ENV NODE_ENV production

RUN if npm run build:${PROFILE} > /dev/null 2>&1; then \
       npm run build:${PROFILE}; \
    else \
       npm run build; \
    fi

### STAGE 2: Setup ###
FROM registry.turacocloud.com/turaco-package/nginx:1.17.6-alpine

## Copy our default nginx config
COPY custom-nginx.conf /etc/nginx/conf.d/

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*
RUN ls -al
## From 'builder' stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=build-stage /app/build /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]
