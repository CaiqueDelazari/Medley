FROM node:22-alpine
WORKDIR /app
COPY servidor/package.json ./servidor/package.json
RUN cd servidor && npm install --omit=dev --package-lock=false
COPY servidor ./servidor
COPY site ./site
ENV NODE_ENV=production SITE_DIR=/app/site UPLOAD_DIR=/app/uploads PORT=3000
RUN mkdir -p /app/uploads/bolin
EXPOSE 3000
CMD ["node", "servidor/servidor.mjs"]
