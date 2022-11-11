FROM node:alpine

ENV MONGODB_CONNECTION=mongodb://mongo:27017/contentdb

WORKDIR /usr/src/app

COPY package*.json /usr/src/app/

RUN npm install

EXPOSE 3001

COPY . /usr/src/app/

ENTRYPOINT [ "node" , "server.js" ]
