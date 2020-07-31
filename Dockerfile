FROM paperbenni/alpine

RUN apk add nodejs npm bash expect wget
RUN npm install surge -g
RUN npm install netlify-cli -g
RUN mkdir -p /home/user
WORKDIR /home/user
COPY start.sh start.sh
COPY utils.sh utils.sh
RUN chmod +x *.sh
CMD "bash start.sh"