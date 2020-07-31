#!/bin/bash

echo "importing functions"

checkvar() {
    if [ -z "$1" ]; then
        echo "variable not found"
        exit
    fi
}

loginnetlify() {
    if ! netlify status | grep -i email; then
        echo "netlify login failed"
        exit 1
    fi
}

# apply surge settings
loginsurge() {
    {
        echo 'machine surge.surge.sh'
        echo '    login '"$SURGEMAIL"
        echo '    password '"$SURGEPASS"
    } >~/.netrc
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
    mv ./*.sh/* ./

    if ! [ -e ./instant.db ]; then
        echo "cloning repo not successful"
        exit 1
    fi

}
