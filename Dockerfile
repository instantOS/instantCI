FROM alpine
RUN apk add nodejs npm bash
RUN npm install -g surge
COPY start.sh start.sh
RUN chmod +x start.sh
CMD "bash start.sh"