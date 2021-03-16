#!/bin/bash

echo "importing functions"

if ! ping -c 1 google.com; then
    echo "no internet"
    exit 1
fi

# change site prefix
if [ -n "$INSTANTOSNAME" ]; then
    echo "using INSTANTOSNAME $INSTANTOSNAME"
else
    INSTANTOSNAME="instantos"
    echo "using default INSTANTOSNAME $INSTANTOSNAME"
fi

checkvar() {
    if [ -z "$1" ]; then
        echo "variable $2 not found"
        exit 1
    fi
}

loginnetlify() {
    echo "checking netlify login"

    if ! netlify status | grep -i email; then
        echo "netlify login failed"
        exit 1
    fi

    checkdb
    mkdir .netlify

    {
        echo '{'
        echo '        "siteId": "'"$NETLIFYID"'"'
        echo '}'
    } >.netlify/state.json

}

# apply surge settings
loginsurge() {
    export SURGE_TOKEN="$SURGETOKEN"
    export SURGE_LOGIN="$SURGELOGIN"
    echo "logging in surge"
    if ! surge list | grep -q instantos; then
        echo 'surge failed'
        return 1
    fi
}

loginfirebase() {
    cleanauth
    cp ../firebase/firebase.json .
    cp ../firebase/firebaserc ./.firebaserc
}

loginvercel() {
    echo "loggin in vercel"
    cleanauth
    mkdir -p ~/.local/share/com.vercel.cli
    pushd ~/.local/share/com.vercel.cli || exit 1

    {
        echo '{'
        echo '  "_": "This is your Now credentials file. DO NOT SHARE! More: https://vercel.com/docs/configuration#global",'
        echo '  "token": "'"$VERCELTOKEN"'"'
        echo '}'
    } >auth.json

    popd || exit 1
    echo "creating project id"
    mkdir .vercel || exit 1
    cp ../vercel/project.json ./.vercel/project.json

}

# database file has to exist
checkdb() {
    if ! [ -e ./instant.db ]; then
        echo "cloning repo not successful"
        exit 1
    fi
}

# get a local copy of the repo
mirrorrepo() {
    if ! curl -s packages.instantos.io | grep -qi instantwm; then
        echo "could not read mirror"
        exit 1
    fi
    mkdir ~/instantmirror
    cd ~/instantmirror || exit 1
    wget -r -m -e robots=off 'http://packages.instantos.io'
    mv ./*/* ./
    checkdb
}

genindex() {
    curl http://packages.instantos.io >index.html
}

deploysurge() {
    echo "deploying surge"
    checkdb
    genindex
    surge . "$INSTANTOSNAME.surge.sh" || echo "surge $INSTANTOSNAME.surge.sh failed"

    if [ "$INSTANTOSNAME" = instantos ]; then
        surge . repo.instantos.io || echo "surge failed"
    fi

    # todo: release site
}

deploynetlify() {
    echo "deploying netlify"
    checkdb
    genindex
    netlify deploy --prod --dir . || echo "netlify failed"
}

deployfirebase() {
    echo "deploying firebase"
    genindex
    firebase deploy || echo "firebase failed"
}

deployvercel() {
    echo "deploying vercel"
    checkdb
    genindex
    vercel . --prod || echo "vercel failed"
}

cleandir() {
    if ! [ -e "$1" ]; then
        return
    else
        echo "cleaning $1"
        rm -rf ./"$1"
    fi
}

cleanauth() {
    echo "cleaning login files"
    cleandir .netlify
    cleandir .vercel
    cleandir .firebase
    cleandir .firebaserc
    cleandir firebase*
    cleandir index.html
}
