FROM paperbenni/alpine

RUN apk add nodejs npm bash expect wget sudo
RUN npm install surge -g
RUN npm install netlify-cli -g
RUN npm install firebase-tools -g

RUN mkdir -p /home/user
WORKDIR /home/user
COPY start.sh start.sh
COPY utils.sh utils.sh
COPY firebase firebase
RUN chmod +x *.sh
CMD "start.sh"