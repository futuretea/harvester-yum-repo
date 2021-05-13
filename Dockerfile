FROM nginx:alpine
RUN mkdir /usr/share/nginx/html/rpms
COPY rpms /usr/share/nginx/html/rpms
RUN mkdir /usr/share/nginx/html/bins
COPY bins /usr/share/nginx/html/bins
COPY index.html /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf