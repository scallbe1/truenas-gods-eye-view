FROM node:24.14-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Pull the current upstream source each time the image is built.
ARG GEV_REPO=https://github.com/bilawalsidhu/gods-eye-view.git
ARG GEV_REF=main

RUN git clone --depth 1 --branch "${GEV_REF}" "${GEV_REPO}" /app

# Puppeteer is used by QA tooling. We don't need to download Chrome
# just to run the application.
ENV PUPPETEER_SKIP_DOWNLOAD=true

RUN npm ci

ENV HOST=0.0.0.0
ENV PORT=4173

EXPOSE 4173

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:4173/').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "4173"]
