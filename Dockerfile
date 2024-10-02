FROM nginx:1.27-alpine
COPY ./main.css ./index.html /usr/share/nginx/html/
CMD [ "nginx", "-g", "daemon off;" ]
