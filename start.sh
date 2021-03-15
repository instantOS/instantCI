#!/bin/bash

echo "starting instantCI"

source ./utils.sh || exit 1

checkvar "$SURGE_TOKEN"
checkvar "$SURGE_LOGIN"

checkvar "$NETLIFYID"
checkvar "$NETLIFY_AUTH_TOKEN"

checkvar "$VERCELTOKEN"

checkvar "$FIREBASE_TOKEN"


# get a local copy of the repo
mirrorrepo

# instantos.surge.sh deployment
loginsurge
deploysurge

# instantos.netlify.app
loginnetlify
deploynetlify

# instantos.vercel.app
loginvercel
deployvercel

# instantos.web.app
loginfirebase
deployfirebase
