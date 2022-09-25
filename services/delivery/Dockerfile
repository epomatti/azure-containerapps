FROM node:16

# update packages
RUN apt update
RUN apt upgrade -y

# create root application folder
WORKDIR /app

# copy configs to /app folder
COPY package*.json ./
COPY tsconfig.json ./
# copy source code to /app/src folder
COPY src /app/src

RUN npm install
RUN npm run build

EXPOSE 3100

CMD [ "node", "./dist/main.js" ]
