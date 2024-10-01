FROM nginx:1.27-alpine
COPY ./main.css ./index.html ./install /usr/share/nginx/html/
CMD [ "nginx", "-g", "daemon off;" ]
