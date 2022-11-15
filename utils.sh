#!/bin/bash

echo "importing functions"

if ! {
    ping -c 1 google.com || curl -s cht.sh
}; then
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
# this is the primary mirror which the others will be synced to
mirrorrepo() {
    if ! curl -s https://packages.instantos.io | grep -qi instantwm; then
        echo "could not read mirror"
        exit 1
    fi

    mkdir ~/instantmirror
    cd ~/instantmirror || exit 1
    wget -r -m -nv -e robots=off 'https://packages.instantos.io'
    mv ./*/* ./
    checkdb
    DBHASH="$(md5sum instant.db | grep -o '^[^ ]*')"
    export DBHASH
}

checkhash() {
    curl "$1"/instant.db >/tmp/tempdb.db

    CHECKHASH="$(md5sum /tmp/tempdb.db | grep -o '^[^ ]*')"

    if [ "$CHECKHASH" = "$DBHASH" ]; then
        echo "repo $1 is already up to date, skipping"
        return 1
    else
        echo "repo $1 needs updating, updating"
        return 0
    fi
}

genindex() {
    curl https://packages.instantos.io >index.html
}

deploysurge() {
    checkhash "http://$INSTANTOSNAME.surge.sh" || return 0
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
    checkhash "https://instantos.netlify.app" || return 0
    echo "deploying netlify"
    checkdb
    genindex
    netlify deploy --prod --dir . || echo "netlify failed"
}

deployfirebase() {
    checkhash "https://instantos.web.app" || return 0
    echo "deploying firebase"
    genindex
    firebase deploy || echo "firebase failed"
}

deployvercel() {
    checkhash "https://instantos.vercel.app"
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
