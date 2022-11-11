FROM node:alpine

ENV MONGODB_CONNECTION=mongodb://mongo:27017/contentdb

WORKDIR /usr/src/app

COPY package*.json /usr/src/app/

RUN npm install

EXPOSE 3001

COPY . /usr/src/app/
# start here references the start script in package.json, it just runs the server.js file, which is what we did in sub module 2
ENTRYPOINT ["npm", "start"]
