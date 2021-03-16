#!/bin/bash

echo "starting instantCI"

source ./utils.sh || exit 1

checkvar "$SURGE_TOKEN" "surgetoken"
checkvar "$SURGE_LOGIN" "surgelogin"

checkvar "$NETLIFYID" "netlifyid"
checkvar "$NETLIFY_AUTH_TOKEN" "netlifyauth"

checkvar "$VERCELTOKEN" "verceltoken"

checkvar "$FIREBASE_TOKEN" "firebasetoken"


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
