ARG NODE_IMAGE=docker.io/library/node:26.12.1-alpine
FROM ${NODE_IMAGE}

WORKDIR /opt/tools
COPY package.json package-lock.json ./

# Versions come from the lockfile; install scripts never run
RUN npm ci --ignore-scripts --no-audit --no-fund

ENV PATH=/opt/tools/node_modules/.bin:$PATH
ENV NODE_PATH=/opt/tools/node_modules
ENV HOME=/tmp
