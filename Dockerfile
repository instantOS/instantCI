FROM paperbenni/alpine

WORKDIR /home/user
RUN apk add nodejs npm bash expect wget sudo
RUN npm install surge -g
RUN npm install netlify-cli
RUN ln -s "$(realpath ./node_modules/netlify-cli/bin/run.mjs)" /usr/bin/netlify && chmod 755 /usr/bin/netlify && /usr/bin/netlify --version
RUN npm install firebase-tools -g
RUN npm install vercel -g

COPY firebase firebase
COPY vercel vercel
COPY start.sh start.sh
COPY utils.sh utils.sh
RUN chmod +x *.sh
CMD "/home/user/start.sh"
