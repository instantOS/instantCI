FROM alpine

RUN apk add nodejs npm bash expect
RUN npm install surge -g
RUN npm install netlify-cli -g

COPY start.sh start.sh
RUN chmod +x start.sh
CMD "bash start.sh"