FROM node:latest as build

WORKDIR /app

COPY package.json yarn.lock /app/

RUN yarn install

COPY . /app/

# RUN CI=1 yarn test

RUN yarn build


FROM nginx:latest

COPY --from=build /app/build /usr/share/nginx/html

COPY --from=build /app/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
