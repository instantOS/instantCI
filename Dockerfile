FROM paperbenni/alpine

RUN apk add nodejs npm bash expect wget sudo
RUN npm install surge -g
RUN npm install netlify-cli
RUN ln -s /node_modules/netlify-cli/bin/run /usr/bin/netlify
RUN npm install firebase-tools -g
RUN npm install vercel -g

RUN mkdir -p /home/user
WORKDIR /home/user
COPY start.sh start.sh
COPY utils.sh utils.sh
COPY firebase firebase
COPY vercel vercel
RUN chmod +x *.sh
CMD "/home/user/start.sh"
