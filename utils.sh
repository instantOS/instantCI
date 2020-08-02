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
        echo "variable not found"
        exit
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
    echo "logging in surge"
    {
        echo 'machine surge.surge.sh'
        echo '    login '"$SURGEMAIL"
        echo '    password '"$SURGEPASS"
    } >~/.netrc
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
    if ! curl -s instantos.surge.sh | grep -qi instantwm; then
        echo "could not read mirror"
        exit 1
    fi
    mkdir ~/instantmirror
    cd ~/instantmirror || exit 1
    wget -r -m -e robots=off 'http://packages.instantos.io'
    mv ./*/* ./
    curl http://packages.instantos.io >index.html
    checkdb
}

deploysurge() {
    checkdb
    surge . "$INSTANTOSNAME.surge.sh"

    if [ "$INSTANTOSNAME" = instantos ]; then
        surge . repo.instantos.io
    fi

    # todo: release site
}

deploynetlify() {
    checkdb
    netlify deploy --prod --dir .
}

cleandir() {
    if ! [ -e "$1" ]; then
        return
    else
        echo "cleaning $1"
        rm -rf "$1"
    fi
}

cleanauth() {
    echo "cleaning login files"
    cleandir .netlify
}
