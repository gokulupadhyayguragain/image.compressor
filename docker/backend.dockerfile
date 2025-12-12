FROM node:18-slim
WORKDIR /app

# copy backend
COPY backend/package.json ./
RUN npm install --production
COPY backend/ ./

# create directories for input/output
RUN mkdir -p /app/../input /app/../output

ENV PORT=3000
EXPOSE 3000
CMD ["node", "index.js"]
