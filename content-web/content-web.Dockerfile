FROM node:alpine

ENV CONTENT_API_URL=http://api:3001

EXPOSE 80
ENV PORT=80

RUN npm install -g @angular/cli@~8.3.4

WORKDIR /usr/src/app

COPY package*.json /usr/src/app/

RUN npm install

COPY . /usr/src/app

RUN ng build 

ENTRYPOINT [ "node", "app.js" ]