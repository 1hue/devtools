# Set from config by `tools build`
ARG NODE_IMAGE
FROM ${NODE_IMAGE}
ARG MIN_RELEASE_AGE

WORKDIR /opt/tools
COPY package.json ./

# Newest versions at least MIN_RELEASE_AGE days old; install scripts never run
RUN npm install --ignore-scripts --no-fund --min-release-age=${MIN_RELEASE_AGE}

ENV PATH=/opt/tools/node_modules/.bin:$PATH
ENV HOME=/tmp
